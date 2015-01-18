# rails-perf

Yves Senn's quote:

    While performance improvements are made in specific areas the overall
    performance of the Rails-Stack is hard to keep track of.
    After the RC's are released we usually get a handful of performance
    regressions that we then address.

    Performance should be a concern when working on the framework.
    Making it possible to see the impact from a specific commit will go a long
    way to improve things.

While [RubyBench](https://rubybench.org) is focused on long-running MRI and Rails metrics, RailsPerf is applying few [short benchmark scripts](https://github.com/kirs/rails-perf/tree/master/benchmarks) on specific release or commit in Rails.

Right now RailsPerf can run benchmarks against specific Gemfile with Rails target listed.
Builds are enqueed to Sidekiq and data is stored in MongoDB.
Every build is compared with major Rails versions.
You can add your own benchmark by commiting the file into `benchmarks/` directory.

### Author

[Kir Shatrov](https://github.com/kirs)

<a href="https://evilmartians.com/">
<img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54"></a>
