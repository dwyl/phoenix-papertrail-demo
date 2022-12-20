# `Phoenix` + `PaperTrail` _`SPIKE`_

A showcase of using `PaperTrail` in a simple `Phoenix` Todo List App.

# Why?

We need a way of capturing the history of `items` in our `App`
to enable "undo" functionality.

# What?

`PaperTrail`: 
[github.com/izelnakri/paper_trail](https://github.com/izelnakri/paper_trail)
Lets you track and record all the changes in your database
and revert back to anytime in history.

This repo demos using `PaperTrail` in a simple Todo List.

# Who?

This quick demo is aimed at people in the @dwyl team
who need to understand how `PaperTrail` is used in our `App`.

# _How_?

## Prerequisites? 

This `Spike` builds upon the foundational work done
in our `Phoenix` Todo List Tutorial:
[dwyl/**phoenix-todo-list-tutorial**](https://github.com/dwyl/phoenix-todo-list-tutorial)

If you haven't been through it,
we suggest taking a few minutes to get up-to-speed.

## 1. Borrow Baseline Code

Let's start by cloning the code from
[dwyl/**phoenix-todo-list-tutorial**].
We are going to be using a version of the repo
that does not have authentication nor API.
This is to simplify the workflow 
and testing.

Clone the repository from the following link -> 
https://github.com/dwyl/phoenix-todo-list-tutorial/tree/ab4470d68f64ed8f5596dd09f3322193317b838e

After cloning the code,
run the following commands to fetch the dependencies
and to set up databases.

```sh
mix deps.get
mix setup
```

After this, if you run `mix phx.server`,
you will be able to run the





# _Deploy_!

Bonus level: deploy to **Fly.io** 
so that anyone can try it.
