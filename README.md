What?
-----

Some cross platform scripts wrapped up in a Ruby gem.

Why?
----

- Ruby runs the same on Windows, Mac, and Linux without needing something like cygwin.
  + Plus, Ruby > Bash.
- RubyGems handles making binstubs for every platform & setting up the path.
  + 'Cuz I want to type `git watch ...`, not `git watch.rb ...`, and not `ruby C:\my\scripts\git-watch ...`

How?
----

```
rake install
```

Thanks!
-------

- Tim Berglund, for the origin [loglive](https://gist.github.com/tlberglund/3714970) implementation.
  This was a nice idea. I've genericized it to "git watch" for observing and responding to ref changes.