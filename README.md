<div align="center">

# `Phoenix` + `PaperTrail` _`Demo`_

A showcase of using `PaperTrail` 
in a simple `Phoenix` Todo List App.

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/dwyl/phoenix-papertrail-demo/ci.yml?label=build&style=flat-square&branch=main)
[![codecov.io](https://img.shields.io/codecov/c/github/dwyl/phoenix-papertrail-demo/master.svg?style=flat-square)](http://codecov.io/github/dwyl/phoenix-papertrail-demo?branch=master)
[![HitCount](http://hits.dwyl.com/dwyl/phoenix-papertrail-demo.svg)](http://hits.dwyl.com/dwyl/phoenix-papertrail-demo)
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat-square)](https://github.com/dwyl/phoenix-papertrail-demo/issues)


# TODO: insert GIF of working PaperTrail UI


</div>
<br />

# Why? 🤷‍

We need a way of capturing the history of `items` in our `App`
to enable "undo" functionality.

# What? 💭

`PaperTrail`: 
[github.com/izelnakri/paper_trail](https://github.com/izelnakri/paper_trail)
Lets you track and record all the changes in your database
and revert back to anytime in history.

This repo demos using `PaperTrail` in a simple Todo List.

# Who? 👤

This quick demo is aimed at people in the @dwyl team
who need to understand how `PaperTrail` is used in our `App`.

# _How_? 👩‍💻

## Prerequisites? 📝

This `Demo` builds upon the foundational work done
in our **`Phoenix` Todo List Tutorial**:
[dwyl/**phoenix-papertrail-demo**](https://github.com/dwyl/phoenix-papertrail-demo)
it is 
[_assumed knowledge_](https://en.wikipedia.org/wiki/Curse_of_knowledge). 

If you haven't been through it,
we suggest taking a few minutes 
to get up-to-speed.

## 1. Borrow Baseline Code from `Phoenix` Todo List Tutorial ♻️


## 2. Add `PaperTrail` to the Project

## 3. Update the code as necessary to enable `PaperTrail` for `items`

Please add _all_ the steps you took. 

### 3.1 Previous Versions of `item.text` in `PaperTrail` `versions` table

Display a _constrained_ screenshot of the `versions` table in your DB UI (e.g: DBeaver) 
Show at least 2 versions, ideally 3 of an `item` being updated.


## X. Add UI to see previous versions of `item.text` stored by `PaperTrail`



## Y. Allow the `person` using the `App` to revert to a previous version of `item.text`




# _Deploy_! 🚀

Bonus level: deploy to **Fly.io** 
so that anyone can try it.

Use the following org: https://fly.io/dashboard/dwyl-phoenix-papertrail
And name the app: `phoenix-papertrail-demo` 
(super original, IKR?!)