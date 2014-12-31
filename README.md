# Bebopt
a more powerful, and coincidentally musical, option parser for node.js/coffee-script

# Why another option parser?
Because too many of the option parsers available for node.js suffer from either being too low-level<sup>**a**</sup> and powerful, or being too abstracted and weak.


# Footnotes
<sup>**a**</sup>
Seemingly *low-level*<sup>***c***</sup> code does not faze me, but there seem to be a lot of developers that get scared when they see that you have to use a `while` loop and a `switch` statement to use them.  I would only avoid *low-level* code if I didn't have the time or the patience for it. (e.g. we need to roll out a release in a week; I've had a long day, I don't want to deal with this crap.)  Even then, however, I would rather just write my own abstraction for the *low-level* stuff, making sure to retain as much, if not all, of the control offered by the original code.

> *Ooooh, Noes!*  I have to write three more lines of code just to do something correctly instead of just writing one line of code and barely managing to get away with it!

<sup>**c**</sup>Apparently, in javascript at least, this refers to any amount of boilerplate code that's longer than 3-5 lines.
