# Bebopt
a more powerful, and coincidentally musical, option parser for node.js/coffeescript

# Why another option parser?
Because too many of the option parsers available for node.js suffer from either being too low-level<sup>**a**</sup> and powerful, or being too abstracted and weak/incorrect<sup>**b**</sup>.  This inequality is the reason I've never written command-line applications in either javascript or coffeescript, outside of work, that is.


# Footnotes
<sup>**a**</sup>
Seemingly *low-level*<sup>***c***</sup> code does not faze me, but there seem to be a lot of developers that get scared when they see that you have to use a `while` loop and a `switch` statement to use them.  I would only avoid *low-level* code where it is possible to do so without sacrificing control.

> *Ooooh, Noes!*  I have to write three more lines of code just to do something correctly instead of just writing one line of code and barely managing to get away with it!

<sup>**b**</sup>As in, options inadvertantly get parsed in the order that they are checked or defined rather than in the order which they appear on the command-line.

<sup>**c**</sup>Apparently, in javascript at least, this refers to any amount of boilerplate code that's longer than 3-5 lines.
