2DO
---
dodelat multicore a multistation

lepsi veliciny
---
.name
.description
.alternative
.parameter
.optional

alternative - cislo skupiny alternativnich velicin. napr. 
        t.alternative = 1
        fs.alternative = 1
        Ts.alternative = 1
        r.alternative = 2
        takze bud t nebo fs nebo Ts bude vyzadovano, ale r je jen jedno ve skupine alternativ 2, takze bude
        pozadovan vzdy, pokud neni optional
parameter - bez randomizace a nevyzaduje dalsi pole mimo .v
optional - nepovinna velicina. hlavne pro parametry? nebo jen pro parametry?

kdyz optional, nemuze byt alternative group? muze! ale proc? by musely byt vsechny...

parts
---
* rnd generator
* general test every alg for inputs/outputs (provides what it promises etc)
* particular test for every alg according alg
datain format
---

if unc, Q.u, Q.c
if guf, Q.d

%---
%
%        COLLUMNS - different observations of the same variable
%        ROWS - different variables
%        e.g.    T_1 T_2 T_3 T_4 .
%                U_1 U_2 U_3 U_4 .
%                F_1 F_2 F_3 F_4 .
%
%**scalar**
%        GUF                             MCM
%.v      (.)                             (.)
%.u      (.)                             (..)    (1, M)
%.d      (.)                             (.)
%.c      (.)                             (.)
%
%**vector**
%        GUF                             MCM
%.v      (:)                             (:)     (rows, 1)
%.u      (:)                             (::)    (rows, M)
%.d      (:)                             (:)     (rows, 1)
%.c      (::)    (rows, == cols)         (::)    (rows, == cols) 
%
%**matrix**
%        GUF                             MCM
%.v      (::)    (rows, cols)            (::)    (rows, cols)
%.u      (::)    (rows, cols)            ((::))  (rows, cols, M)
%.d      (::)    (rows, cols)            (::)    (rows, cols)
%.c      ((::))  (rows, cols, ???)       ((::))  (rows, cols, ???)
%
---

        ROWS - different observations of the same variable
        COLLUMNS - different variables
        e.g.    T_1 U_1 F_1
                T_2 U_2 F_2
                T_3 U_3 F_3
                T_4 U_4 F_4
                .   .   .

**scalar**
        GUF                             MCM
.v      (.)                             (.)
.u      (.)                             (:)    (M, 1)
.d      (.)                             (.)
.c      (.)                             (.)

**vector**
        GUF                             MCM
.v      (..)    (1, cols)               (..)    (1, cols)
.u      (..)                            (::)    (M, cols)
.d      (..)                            (..)    (1, cols)
.c      (::)    (rows, == cols)         (::)    (rows, == cols) 

**matrix**
        GUF                             MCM
.v      (::)    (rows, cols)            (::)    (rows, cols)
.u      (::)    (rows, cols)            ((::))  (rows, cols, M)
.d      (::)    (rows, cols)            (::)    (rows, cols)
.c      ((::))  (rows, cols, ???)       ((::))  (rows, cols, ???)





ROWS vs COLLUMNS
================

Three issues have been raised here, and I'll present them and provide my
views:
1) Which is better; rows or columns: Internally, it doesn't really make that
much difference. However, MATLAB is designed to operate column-wise, so that
sum(X) sums the columns in a matrix. I like to think of MATLAB dealing with
the row/column issue as saying that columns contains different variables,
and rows contain different observations of those variables. Thus, the rows
might be different observations in time of three different temperatures,
which are represented in columns A, B, and C. This is consistent with
MATLAB's behaviour for sum, mean, etc., which produce "the sum of all my
observations for each variable".

2) [1:10] and [1 2 3 4] being less efficient: I'm not sure they are. In
terms of memory, there's no difference; MATLAB still stores them the same
(one after the other). I tested a summation of 1:N and (1:N)' M times each,
and although there was a difference in execution speed, it was around 0.01
seconds in 2.4 seconds, or 0.4%. I'm not sure my system clock is that
accurate :-)

3) Why does 1:N produce a row vector? Typically, we use that syntax for
enumerating through a loop. Loops operate on each column of the looping
variable, so the default mechanism works on a for loop:
  for k=1:N
    % somethign to do with k
  end
Now I know what you're thinking: isn't the for loop violating (1) above? I
don't think so, because control variables like k above are not really
observations, but indices. Again, I think the MATLAB choice was for
practical reasons;
  for k=(1:N)'
looks clumsy.

That's how I like to think of the row- vs column-matrix concept. Rows are
observations of the same thing; columns are different "things".
