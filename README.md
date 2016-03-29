What?
-----

Some cross platform scripts wrapped up in a Ruby gem.

Why?
----

- Ruby runs the same on Windows, Mac, and Linux without needing something like cygwin.
- RubyGems handles making binstubs for every platform & adding the binaries to your PATH.

How?
----

```
git clone https://github.com/jbreeden/git-scripts
cd git-scripts
rake install # May need sudo
```

Thanks!
-------

- Tim Berglund, for the origin [loglive](https://gist.github.com/tlberglund/3714970) implementation.
  This was a nice idea. I've genericized it to "git watch" for observing and responding to ref changes.
