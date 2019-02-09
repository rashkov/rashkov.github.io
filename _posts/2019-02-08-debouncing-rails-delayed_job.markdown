---
layout: post
title: "Debouncing/throttling delayed_job in Rails"
date:   2019-02-08 17:38:50 -0500
---

At work we make good use of the Solr search engine to index our data and make it searchable by internal tools, our public facing websites, and mobile applications.

Keeping the searchable data up-to-date is a little bit tricky. We must remember to call model.index() to update the Solr index with our model's latest changes.
{% highlight ruby %}
  class Fooz < ApplicationRecord
    def update_index
      self.index
    end
  end
{% endhighlight %}


This can take a few seconds for a single model, and sometimes we want to index many models at once. We want to avoid slowing down our Rails server, so we offload these tasks to another machine via the delayed_job gem. Now we just schedule the task and our delayed_job server takes care of the indexing for us:

{% highlight ruby %}
  class Fooz < ApplicationRecord
    def update_index
      self.delay.index
    end
  end
{% endhighlight %}

Except, we still have to remember to call that index method one way or another. Wouldn't it be nice to do that any time our model gets updated? While callbacks are frequently considered a Rails antipattern, I think this is one of the cases where using one is appropriate.
{% highlight ruby %}
  class Fooz < ApplicationRecord
    after_save :update_index
    def update_index
      self.delay.index
    end
  end
{% endhighlight %}

One problem though: We have a webpage where someone enters the data for this model. That form has many inputs, and the data gets repeatedly POST'ed up to the model as each input is filled in turn. This is accomplished using JavaScript keyup events, or input blur events. We do this to avoid having a "submit" or a "save" button on the form. It's a delightful piece of the user experience, but unfortunately it introduces some complexity to our code.

In this case, we don't want to the user to overwhelm our delayed_job server by updating the model many times within the span of a few seconds. If only we could repeatedly schedule this job with delayed_job, but do so in a debounced or throttled way where it only runs once every X seconds.

{% highlight ruby %}
class Fooz < ApplicationRecord
  after_save :update_index
  def update_index
    cache_key = "FOOZ_UPDATE_INDEX_#{self.id}"
    delay_seconds = 5
    queued_job = Rails.cache.fetch(cache_key)
    queued_job.destroy if queued_job
    new_queued_job = self.delay(run_at: delay_seconds.seconds.from_now).index
    Rails.cache.write(
      cache_key,
      new_queued_job,
      expires_in: delay_seconds.seconds
    )
  end
end
{% endhighlight %}

How does this work? 

When we offload a method to delayed_job, as in self.delay.index (instead of the non-delayed self.index), we get back a delayed_job model. That model is an entry in delayed_job's table, which acts as a job queue that delayed_job regularly checks and processes. 

The first time we call update_index, our cache is empty, so the only code to actually do anything is the following:
{% highlight ruby %}
new_queued_job = self.delay(run_at: delay_seconds.seconds.from_now).index
Rails.cache.write cache_key, new_queued_job, expires_in: delay_seconds.seconds
{% endhighlight %}

This creates a delayed job which is set to run in five seconds. Then we save a copy of that job to the Rails cache. We tell the cache to only store this item for 5 seconds.

Please note how we use a key which is unique to that particular model (since the cache key has the model's ID in it), this way our debounce is specific to a particular model and not all Fooz models. 

If update_index gets called again within the next five seconds, then we will find the old, not-yet-executed job waiting for us in the cache. We then destroy it before creating our new job, which prevents delayed_job from doing anything with it in the future. We then put the new job into the cache under the same cache key. If five seconds pass without update_index being called, then that job will expire from the cache and it will execute successfully.

Does it work? "Show us the receipts!", you say?

{% highlight ruby %}
[1] pry(main)> Fooz.last.update_index; puts "#{Delayed::Job.count}
  Queued Jobs"; puts "Current time: #{Time.now}";
  Fooz Load (0.9ms)  SELECT  "fooz".* FROM "fooz" ORDER BY "fooz"."id"
  DESC LIMIT $1  [["LIMIT", 1]]
  (0.4ms)  BEGIN
  SQL (0.9ms)  INSERT INTO "delayed_jobs" ("handler", "run_at", "created_at",
  "updated_at") VALUES ($1, $2, $3, $4) RETURNING "id"  [
  ["handler", "--- !ruby/object:Delayed::PerformableMethod
  object: !ruby/object:Fooz
  raw_attributes:
  id: 1208591
  method_name: :index
  args: []
  "], ["run_at", 2019-02-08 23:56:22 UTC], ["created_at", 2019-02-08 23:56:17
  UTC], ["updated_at", 2019-02-08 23:56:17 UTC]] (2.8ms)  COMMIT
  (0.7ms)  SELECT COUNT(*) FROM "delayed_jobs"
1 Queued Jobs
Current time: 2019-02-08 18:56:17 -0500
[2] pry(main)> puts "#{Delayed::Job.count} Queued Jobs"; puts "Current time:
                  #{Time.now}";
  (0.8ms)  SELECT COUNT(*) FROM "delayed_jobs"
1 Queued Jobs
Current time: 2019-02-08 18:56:18 -0500
[7] pry(main)> puts "#{Delayed::Job.count} Queued Jobs"; puts "Current time:
                  #{Time.now}";
  (0.8ms)  SELECT COUNT(*) FROM "delayed_jobs"
1 Queued Jobs
Current time: 2019-02-08 18:56:25 -0500
[8] pry(main)> puts "#{Delayed::Job.count} Queued Jobs"; puts "Current time:
                  #{Time.now}";
  (0.7ms)  SELECT COUNT(*) FROM "delayed_jobs"
0 Queued Jobs
Current time: 2019-02-08 18:56:27 -0500
{% endhighlight %}

It took more than five seconds for the task to be completed, which is what was
desired when we passed the run_at option to the delay() method.

{% highlight ruby %}
[1] pry(main)> Fooz.last.update_index; puts "#{Delayed::Job.count} Queued
        Jobs"; puts "Current time: #{Time.now}";
  Publication Load (1.2ms)  SELECT  "publications".* FROM "publications"
  WHERE "publications"."name" = $1 LIMIT $2  [["name", "Online"], ["LIMIT",
  1]]
  Fooz Load (0.8ms)  SELECT  "fooz".* FROM "fooz" ORDER BY "fooz"."id" DESC
  LIMIT $1  [["LIMIT", 1]]
  (0.4ms)  BEGIN
  SQL (0.8ms)  INSERT INTO "delayed_jobs" ("handler", "run_at", "created_at",
  "updated_at") VALUES ($1, $2, $3, $4) RETURNING "id"  [["handler", "---
  !ruby/object:Delayed::PerformableMethod
  object: !ruby/object:Fooz
  raw_attributes:
  id: 1208591
  method_name: :index
  args: []
  "], ["run_at", 2019-02-08 23:59:47 UTC], ["created_at", 2019-02-08 23:59:42
  UTC], ["updated_at", 2019-02-08 23:59:42 UTC]] (2.9ms)  COMMIT
  (0.5ms)  SELECT COUNT(*) FROM "delayed_jobs"
1 Queued Jobs
Current time: 2019-02-08 18:59:42 -0500
[2] pry(main)> Fooz.last.update_index; puts "#{Delayed::Job.count} Queued
        Jobs"; puts "Current time: #{Time.now}";
  Fooz Load (0.8ms)  SELECT  "fooz".* FROM "fooz" ORDER BY "fooz"."id" DESC
  LIMIT $1  [["LIMIT", 1]]
  (0.4ms)  BEGIN
  SQL (0.3ms)  DELETE FROM "delayed_jobs" WHERE "delayed_jobs"."id" = $1 
  [["id", 376261]]
  (2.7ms)  COMMIT
  (0.5ms)  BEGIN
  SQL (0.5ms)  INSERT INTO "delayed_jobs" ("handler", "run_at", "created_at",
  "updated_at") VALUES ($1, $2, $3, $4) RETURNING "id"  [["handler", "---
  !ruby/object:Delayed::PerformableMethod
  object: !ruby/object:Fooz
  raw_attributes:
  id: 1208591
  method_name: :index
  args: []
  "], ["run_at", 2019-02-08 23:59:48 UTC], ["created_at", 2019-02-08 23:59:43
  UTC], ["updated_at", 2019-02-08 23:59:43 UTC]] (1.4ms)  COMMIT
  (0.4ms)  SELECT COUNT(*) FROM "delayed_jobs"
1 Queued Jobs
Current time: 2019-02-08 18:59:43 -0500
[3] pry(main)> Fooz.last.update_index; puts "#{Delayed::Job.count} Queued
        Jobs"; puts "Current time: #{Time.now}";
  Fooz Load (0.8ms)  SELECT  "fooz".* FROM "fooz" ORDER BY "fooz"."id" DESC
  LIMIT $1  [["LIMIT", 1]]
  (0.4ms)  BEGIN
  SQL (0.6ms)  DELETE FROM "delayed_jobs" WHERE "delayed_jobs"."id" = $1 
  [["id", 376262]]
  (2.7ms)  COMMIT
  (0.4ms)  BEGIN
  SQL (0.9ms)  INSERT INTO "delayed_jobs" ("handler", "run_at", "created_at",
  "updated_at") VALUES ($1, $2, $3, $4) RETURNING "id"  [["handler", "---
  !ruby/object:Delayed::PerformableMethod
  object: !ruby/object:Fooz
  raw_attributes:
  id: 1208591
  method_name: :index
  args: []
  "], ["run_at", 2019-02-08 23:59:48 UTC], ["created_at", 2019-02-08 23:59:43
  UTC], ["updated_at", 2019-02-08 23:59:43 UTC]] (1.6ms)  COMMIT
  (0.7ms)  SELECT COUNT(*) FROM "delayed_jobs"
1 Queued Jobs
Current time: 2019-02-08 18:59:43 -0500
{% endhighlight %}

Running that method multiple times within five seconds does not create additional delayed_jobs. You can see it DELETE the old delayed_job, and INSERT a new one. That means that our cache is working properly.

{% highlight ruby %}
[5] pry(main)> puts "#{Delayed::Job.count} Queued Jobs"; puts "Current time:
        #{Time.now}";
  (0.7ms)  SELECT COUNT(*) FROM "delayed_jobs"
0 Queued Jobs
Current time: 2019-02-08 19:01:06 -0500
{% endhighlight %}

Finally, checking the queue some time later, we find it empty again as our job completed and came off of the queue.

In conclusion, debouncing is an amazing concept that is useful for rate limiting actions on the front-end, as well as the back-end.
