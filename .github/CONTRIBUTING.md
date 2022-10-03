# Contributing

## Basic expectations

The project has a [code of conduct](https://github.com/LunarWatcher/auto-pairs/blob/master/.github/CODE_OF_CONDUCT.md) you're expected to follow.

## Asking questions, reporting bugs, posting feature requests, etc.

This repo has enabled both discussions and issues, and the general distribution is:
* Bugs and feature requests go into issues
* Questions on usage go in discussions

This distribution is largely because discussions center around answerability, and there's not really that many proper answers to a feature request or a bug. Aside votes potentially indicating usefulness, but that's beside the point.

That said, it's not always obvious what goes where. Something could be a bug, but could also just be a bad configuration. It's therefore expected that you make an attempt at figuring out where it's best suited, but there's no consequences for posting in the wrong category. At worst, it can just be converted, no harm done.

## Pull requests

We welcome pull requests, but as this project has been getting more complex, there's a few meta guidelines surrounding these.

### Versioning

There's a variable that keeps track of versions. Simply put, if you're making the first PR after a version has been tagged, you have to increment the number by one. If commits have been made since the previous tag, skip this step.

And again, this only applies to the number in `autoload/`. I'll take care of the more semantic side of versioning. This step is largely to make sure `g:AutoPairsVersion` doesn't indicate an old version with features that aren't a part of the tagged version.

### Changelog

The project has a changelog. As evidenced by the already existing content of the changelog, it doesn't have to be completely exhaustive or detailed, but a line or two describing any applicable changes should be a part of your PR.

The changelog loosely uses the [keepachangelog](https://keepachangelog.com/en/1.0.0/) 1.0.0 standard, though with a few variations. You can largely just base it off the existing entries if nothing for the current version exists.

### Testing

GitHub automatically builds tests when you commit in a PR (though new contributors need to have the run manually approved in order to start, because GitHub said so). The tests always have to pass. If some core functionality was changed that means the failing test(s) need changes, these must be made for the PR to be approved.

Adding tests is highly encouraged, and only required for bug fixes. Regression tests are extremely important for ensuring bugs don't happen again later.
