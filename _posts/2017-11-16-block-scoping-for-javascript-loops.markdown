---
layout: post
title: "printing/console.log from a for loop, block scoping, and ES5 vs ES6"
date:   2017-11-16 15:24:35 -0500
categories: javascript code
---
...in which our protagonist discovers the great power of ES6 block-scoped variables
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
