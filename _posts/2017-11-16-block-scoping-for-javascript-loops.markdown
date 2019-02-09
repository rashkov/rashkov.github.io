---
layout: post
title: "...in which our protagonist discovers the great power of ES6 block-scoped variables"
date:   2017-11-16 15:24:35 -0500
---
The quirks of running console.log from within a Javascript for-loop was one of the first, horrifying discoveries that I made as a newly minted javascript developer. I quickly stopped using for-loops anywhere in my code and switched to underscore/lodash's looping constructs -- _.each() and _.map().

Now with ES6 block scoping, for-loops are safe to use again! Let's have a look:

{% highlight javascript %}
// A simple async function that resolves immediately
let asyncFn = ()=> {
  let handlers = (resolve, reject)=> {
    resolve();
  }
  return (new Promise(handlers));
}

// Lack of default block scoping can be confusing. Especially with for loops
// Say, someone might start with this:
for (var i = 0; i < 10; ++i) {
 asyncFn().then(function() { console.log(i); });
} // Prints all 10s

// Then when they realize why this doesn't work, try something like:
for (var i = 0; i < 10; ++i) {
  var j = i; // this is inside the block, so it's scoped to it, right?
  asyncFn().then(function() { console.log(j); });
} // Prints all 9s

// Turns out that for loops don't actually create block scoping,
// even though they use curly braces

// Have to create scope/closure using
// an immediately-invoked-function-expression (IIFE)
for (var i = 0; i < 10; ++i) {
  (function(){
    var j = i;
    asyncFn().then(function() { console.log(j); });
  })();
}

/*  Can achieve the same thing using
 *  the fancy new (ES6) block-scoped
 *  let declaration
 */
for (var i = 0; i < 10; ++i) {
  let j = i;
  asyncFn().then(function() { console.log(j); });
}
{% endhighlight %}
