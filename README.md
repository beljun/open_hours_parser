# Opening Hours Parser

This project parses opening hours of stores as they are commonly written. The code is in pure Ruby with no additional dependencies outside of the stock install. This basically means that everything was hand-coded. Obviously, this shouldn't be done in real life. Instead, one should start with the many existing NLP libraries -- probably a parser generator using a subset or custom grammar.

That being said, this implementation uses a tokenizer, tagger, and chunker (shallow parser). The parsed data are then passed to an OpenHours class that takes care of normalizing and merging the ranges and formatting the final output according to the specs.

## Setup
A relatively new version of Ruby (>= 1.9.3) is required to run this module. Most updated versions of Linux and OS X (Yosemite and Mavericks) come prebuilt with Ruby. To check your version, please type:
```sh
$ ruby -v
ruby 2.0.0p481 (2014-05-08 revision 45883) [universal.x86_64-darwin14]
```
If the version is >= 1.9.3, then you're good and can proceed to run the [tests](#on-native-ruby).

In case yours doesn't meet the version requirements, the easiest way to get Ruby without touching the OS is via JRuby (a Java-based Ruby environment). Requires at least Java 6. To use JRuby:

1. Download the package from the [JRuby website](https://s3.amazonaws.com/jruby.org/downloads/1.7.19/jruby-bin-1.7.19.zip).
2. Unzip and move the folder to your home. You should then have a folder like ```~/jruby-1.7.19/```.
3. On a terminal session, add JRuby to the executable path:

    ```
    export PATH=~/jruby-1.7.19/bin:$PATH
    ```

    You can also do this permanently by editing ```~/.bash_profile```.

4. Verify that you can run ```jruby -v``` and it shows something like:

    ```sh
    $ jruby -v
    jruby 1.7.19 (1.9.3p551) 2015-01-29 20786bd on Java HotSpot(TM) 64-Bit Server VM 1.8.0-b132 +jit [darwin-x86_64]
    ```

4. You can now proceed to running the [tests](#on-jruby).

## Running the Tests

The tests are in files under ```test/```. The core tests as included in the original specs are in ```test_basic.rb```. Additonal enhancements such as inverted time and day phrasing have their tets in ```test_extras.rb```.

Please ```cd``` to the module's top-level directory prior to pasting the commands below.

### On Native Ruby

```sh
$ ruby ./test/test_basic.rb --verbose
$ ruby ./test/test_extras.rb --verbose
```
  
### On JRuby

```sh
$ jruby ./test/test_basic.rb --verbose
$ jruby ./test/test_extras.rb --verbose
```

## Running Interactively

You can also fire up an IRB console and interactively parse strings. You should ```cd``` to the module's top-level.

```sh
$ irb
```
And within IRB, you can

```ruby
irb(main):001:0> require './lib/hours.rb'
=> true
irb(main):002:0> Hours.parse "Sunday: 07:30 - 23:00"
=> "S0:0730-2300"
irb(main):003:0> Hours.parse "Mon-Fri: 11:45-16:30; 17:45-23:30"
=> "S1-5:1145-1630,1745-2330"
```

