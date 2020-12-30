title: Listing and Starting modernUI applications in C#
date: 2017-03-04
tags: C#,Programming
---
<!-- Licensed under the CC BY-NC-SA 4.0 -->
<section markdown="1">
# Context (sort of)

Recently I've been trying to improve my personnal project
[Windmenu](https://github.com/cafehaine/windmenu), and one of the problems I
found, was that while crawling through the Start Menu to retreive all
applications, ModernUI applications were not found.

I soon realised that, the usual directory `%appdata%\Microsoft\Windows\Start Menu`
did in fact not contain those shortcuts.

So where to find them?

A few websites point to `shell:::{4234d49b-0245-4df3-B780-3893943456e1}`, and
that is true, but you sadly cannot acess that from C#.

The truth is: I don't know "where" to find them, but I know "how". This is how

</section><section markdown="1">

# How I did it
## Listing the applications

To be honest I am not proud of this method, as it relies on the registry, which
is most of the time not a good idea.

If you go to `HKEY_CURRENT_USER\Software\Classes` in regedit, you will see all
the file/url extensions, but also what we are looking for.

Here, are a few keys, named using the following pattern: `AppX[a-z0-9]*`. Those
are the applications. Keep them.

These are the keys we are looking for, as they contain in the Application subkey
the value of `AppUserModelID`.

`AppUserModelID` is what is needed to later, start a modernUI application.

## Getting the name of the application

Once again, not proud of this. I am sure there is a better way to do it.

What I did was retrieve the "name" from the AppUserModelID with this regex
`(.+\.)+([a-zA-Z]*)_.*!.*` and then "prettyfied" it, adding spaces where needed.

The registry key contains a value named `ApplicationName`, but I could not find
a way to use this to retreive the localized name.

## Starting the application

Here I didn't do much, as user sankar over at StackOverflow already
[explained the whole process](https://stackoverflow.com/questions/12925748/iapplicationactivationmanageractivateapplication-in-c)
of starting a modernUI application using it's `AppUserModelID`.

This involves some com interfacing, and I am not going to go any more deeper
than this about the subject, since you can just check out my code
[here](https://github.com/cafehaine/windmenu/blob/master/Server/UniversalApplicationHelper.cs)
to see how I did it.

</section><section markdown="1">

# Conclusion

There must be a better way. I don't know why Microsoft made it so hard to start
a modernUI application from a regular application, but they did it.

Should you do it the way I did it? No. It's bad, and I realy hope I will find a
way to do it better.

Does it work? Yes, as long as Microsft does not decide to change the registry
keys this is based on.

Anyway, I hope I will be able to find a new way to do this, which I will post
here.

</section>
