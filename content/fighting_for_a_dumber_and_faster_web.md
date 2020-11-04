title: Fighting for a dumber and faster web
tags: html,css,static,web
date: 0001-01-01
---
<section markdown="1">

# Introduction
Recently, I've re-written my website to be dumber, faster, and more secure. How
did I do it?. It's simple, no more PHP or any server-side code, and no more
javascript. I've gone back to the pre CGI 1993 era.

</section><section markdown="1">

# What's the problem with current websites?

## The client side

Too many frameworks and libraries are used. This causes the websites to feel
slow to load on slow connections, and also slow to use if you're using a low-end
device, like a 5 years old phone.

This is why this website has 0 javascript. (yup, none, you can check.)

This website is made using only HTML5 and CSS3. This means that some old browser
that you shouldn't be using for security reasons won't display it correctry, but
do we really care about those?

## The server side

Caching, databases, web servers, reverse proxies, containers, node.js packages…
The stack that once was LAMP has become huge, complex, and hard to secure. This
setup might feel simpler for users of high level languages that like running
some docker images from random users, but abstraction of all of that
infrastructure means most users don't know how and what their server run.

This is why this website is static, requiring only Linux, and Nginx. Everything
is computed only once, when I re-generate the website after adding an article.

</section><section markdown="1">

# What's wrong with computing stuff client-side?

Computing something server-side means that you compute it once for potentially
thousands of served pages. When you run that computation on the client, you've
gone from one computation to thousands. A lot more energy is wasted, and your
page feels slower to the user, since the browser had to compute stuff before
displaying the page.

But once again, maybe you don't even need server-side code. More code means more
potential security risks, but also worse performances.

</section><section markdown="1">

# Yeah but how can I do X without javascript?

It depends. One of the things you won't be able to do is Ajax. But is it really
a problem? If your website is much faster to load, is reloading a page after
filling a form that bad? Probably not.

Server-side code will most of the time be able to solve your problems.

For other things, html5 might already allow you to do such a thing:

You want to create a spoiler element that hides some text? Just use the
`details` element.

Want to have a popup menu? it's a bit more complex, but with hidden checkboxes,
you can achieve that.

Browsing the mdn website will allow you to discover a whole bunch of cool new
features, like css grids, and video subtitle tracks, that work without any
javascript.

Fun fact, depending on your OS, if you change the theme from light to dark, this
website will also adapt! CSS3 is pretty cool.

</section><section markdown="1">

# In conclusion

I really hope that more people will think twice before adding huge frameworks
and assets to their websites. Current HTML5 and CSS3 specs allows us to have
quite complex websites, and javascript isn't really needed anymore.

If you still think that using javascript to prevent loading full pages is a good
idea, check out this [blog article by Carter Sande](https://carter.sande.duodecima.technology/javascript-page-navigation/)
about this subject.

</section>
