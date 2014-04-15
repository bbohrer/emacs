;; A very small corpus consisting of the plain-text lecture notes for 15-859:
;; http://www.cs.cmu.edu/~avrim/ML14/index.html
;; Machine-learning-speak, like Biblical English, is a very pathological
;; form of speaking, and some people who are fluent in Machine Learning
;; can barely communicate in conversational American English.
(setq corpus "
VC-dimension II
* Sauer's lemma
* Proving the main result

Plan for today: two very nice proofs.
1 Sauer's lemma: the number of different ways of labeling m points
    using functions in class C is at most {m choose leq d}, where d=VCdimC.
2 the uniform convergence bound where we roughly replace |C| with
    C[2m].

Given a concept class C and set of examples S, let C[S] be the set of
possible labelings of S using concepts in C.  C[m] = max_{S:|S|=m} |C[S]|.

SAUER'S LEMMA: C[m] <= {m choose leq d}, where d = VCdimC and we define
{m choose  leq d} = # ways of choosing d or fewer items out of m.

Note: {m choose leq d} = {m-1 choose leq d} + {m-1 choose leq d-1}

	Proof: to choose d or fewer out of m you either choose the
	first element and then d-1 or fewer out of the remaining m-1 or you
	don't, and then choose d or fewer out of the remaining m.

PROOF OF SAUER'S LEMMA: Let's say we have a set S of m examples.  We
want to bound |C[S]|.

Pick some x in S.  So, we know that C[S - {x}] has at most {m-1
choose leq d} distinct partitions by induction.

How are there more labelings of S are there than of S - {x}?  As in
the special case we examined last class, |C[S]| - |C[S - {x}]| = the
number of pairs in C[S] that differ only on x, since these are the
ones that collapse when you remove x.

For each pair, let's focus on the one that labels x positive.
Let C' = {c in C[S] that label x positive for which there is another
concept in C[S] that is identical to c except it labels x negative}.

Remember, these are concepts that are only defined on S

Claim: VCDIMC >= VCDIMC' + 1.
Proof: Pick set S' of pts in S that are shattered by C'. S' doesn't
include x since all functions in C' label x positive.  Now, S' U {x}
is shattered by C because of how C' was defined.

This means VCDIMC' <= d-1, so |C'[S]| <= {m-1 choose leq d-1} by
induction and we are done.  QED

THEOREM 1: For any class C, distrib D, if we draw a sample S from D of
size:
    m > 2/epsilon[log_22C[2m] + log_21/delta],
then with prob 1-delta, all h with err_Dh>epsilon have err_Sh>0.

Proof: Given set S of m examples,  define A = event there exists h in
C with err_Dh>epsilon but err_Sh=0.

We want to show Pr[A] is low.

Now, consider drawing *two* sets S, S' of m examples each.  Let A be
defined as before.  Define B = event that there exists
a concept h in C with err_Sh=0 but err_{S'}h >= epsilon/2.

   Claim: Pr[A]/2 <= Pr[B].  So, if Pr[B] is low then Pr[A] is low.

   Pf: Pr[B] >= Pr[B|A]Pr[A].  Conditioned on event A pick some such
   h, Pr[B|A] > 1/2 by Chernoff since m > 8/epsilon.  the bad h has
   true error > epsilon so unlikely it will have observed error <
   epsilon/2.  This means that Pr[B] >= Pr[A]/2. QED

Now, show Pr[B] is low.  Note: no longer need to talk about "bad"
hyps.  Reason: for really good hyps, unlikely to satisfy the second part

To do this, consider related event: draw S = {x1, x2, ..., xm} and S'
= {x1', x2', ..., xm'} and now create sets T, T' using the following
procedure Swap:

  For each i, flip a fair coin:
     - If heads, put xi in T and put xi' in T'.
     - If tails, put xi' in T and put xi in T'.

Claim: T,T' has the same distribution as S,S'.  So, equivalent to
bound the probability of B_T = event that exists concept h in C with
err_Th=0 but err_{T'}h >= epsilon/2.

What's the point of all this?? Instead of Pr_{S,S'}[B] we have
Pr_{S,S',swap}[B_T].  Will show this is small by showing that for
*all* S,S', Pr_{swap}[B_T] is small.

In particular, the key here is that even if there are infinitely many
concepts in C, once we have drawn S,S', the number of different
labelings we have to worry about is at most C[2m], and will argue that
whp over the randomness in swap none of them will hurt us.

Now, fix S,S' and fix some labeling h.  If, for any i, h makes a
mistake on *both* xi and xi' then Pr_{swap}err_Th=0 = 0.  If h
makes a mistake on less than epsilon*m/2 points, then
  Pr_{swap}err_{T'}h >= epsilon/2=0.
Else,
  Pr_{swap}err_Th=0 AND err_{T'}h >= epsilon/2 <= 2^{-epsilon*m/2}.
Now, we apply union bound:

   Pr[B] <= C[2m] * 2^{-epsilon*m/2}.   Set this to delta/2.

That's it.  Gives us Theorem 2.

How about an agnostic/uniform-convergence version of Theorem 1?

Theorem 1': For any class C, distrib D, if:
	m > 8/epsilon^2[ln2C[2m] + ln1/delta]
then with prob 1-delta, all h in C have |err_Dh-err_Sh| < epsilon.

Just need to redo proof using Hoeffding.  Draw 2m examples:

A = event that on 1st m, there exists hyp in C with empirical and
true error that differ by at least epsilon.  This is what we want to
bound for the theorem.

B = event that there exists a concept in C whose empirical error on
1st half differs from empirical error on 2nd half by at least
epsilon/2.

Pr[B|A] >= 1/2 so Pr[A] <= 2*Pr[B].  Now, show Pr[B] is low:

As before, let's pick S, S' and do the random procedure swap to
construct T, T'.  Show that for *any* S,S',
  Pr_{swap}exists h in C with |err_Th-err_{T'}h| > epsilon/2
is small.

Again, at most C[2m] labelings of S union S', so fix one such h.

Can think of any i such that exactly one of hxi and hxi' is
correct as a coin.  Asking: if we flip m' <= m coins, what is
Pr|heads-tails| > epsilon*m/2.  Write this as being off from
expectation by more than epsilon*m/4 = 1/4epsilon*m/m'm'.
By Hoeffding, Prob is at most 2*e^{-epsilon*m/m'^2 m'/8}
and this is always <= 2*e^{-epsilon^2 m/8}.  Now multiply by C[2m] and
set to delta.



To get Cor 3, use: C[2m] <= {2m choose leq d} <= 2em/d^d.  Then just some
rearranging...


More notes:  It's pretty clear we can replace C[2m] with a 'high
probability' bound with respect to the distribution D.  I.e. a number
such that with high probability, a random set S,S' of 2m points drawn
from D wouldn't have more than this many labelings.  With
extra work, you can reduce it further to the *expected* number of
labelings of a random set of 2m points.  In fact, there's been a lot
of work on reducing it even further to 'the number of possible
labelings of your actual sample'.  See, e.g., the paper 'Sample Based
Generalization Bounds'.

		15-859B Machine Learning Theory            02/03/14

* Recap of growth-function upper-bounds
* Basic definitional questions in the PAC model
* Weak vs Strong learning.  Boosting


[Start with recap from last time -- see previous notes]

Today: take a look at some basic questions about the PAC model.  This
will lead us into our next topic: boosting.

We defined the notion of PAC-learnability like this prediction
version where not restricting form of hypothesis:

Defn1: Alg A PAC-learns concept class C if for any target in C, any
distribution D, any epsilon, delta > 0, with probability 1-delta, A
produces a poly-time evaluatable hypothesis h with error at most
epsilon.

Say C is PAC-learnable if exists A that does this with # examples and
running time polynomial in relevant parameters.

ISSUE #1: DO WE NEED TO SAY FOR ALL DELTA?

On your homework assignment, you will show that if we change the definition
to say delta = 1/2, then this doesn't affect what is learnable.  In
fact, could even change
  for any delta > 0, succeeds with probability at least 1-delta
to
  for some delta' > 0, succeeds with probability at least delta'

Basically, given an algorithm satisfying this second definition, we
could just run it N = 1/delta'log2/delta times on fresh data each
time, so that whp at least one was successful, and then test the
hypotheses on a new test set of size O1/epsilon logN/delta.

So, delta not so important. Can fix to 1/2 or even 1 - 1/n^c and still
get same notion of polynomial learnability.

ISSUE #2: DO WE NEED TO SAY FOR ALL EPSILON?

Def 2: Let's say that alg A WEAK-LEARNS class C if for all c in C, all
distributions D, THERE EXISTS gamma, delta' > 1/polyn s.t. A
achieves error at most 1/2 - gamma with prob at least delta'.

I.e., with some noticeable probability you get noticeable correlation.
[using gamma to denote the gap]

Question: suppose we defined PAC model this way, does this change the
notion of what is learnable and what is not?

Answer, it doesn't.  Given an algorithm that satisfies Def2, can
boost it to an algorithm that satisfies Def1.

Note: we can handle delta as before.  So, we'll ignore delta and
assume that each time, we get a hypothesis of error <= 1/2 - gamma.

Boosting: preliminaries


We're going to have to use the fact that algorithm A works in this
weak way over *every* distribution.  If you look at the distribution
specific version of this question, the answer is NO.  E.g., say your
target function was x is positive if its first bit equals 1 or if x
satisfies some hard crypto property e.g., viewed as an integer, x is
a quadratic residue mod some large N.  Then, it's easy to get error
25% over uniform random examples: you predict positive if x1=1 and
whatever you want otherwise.  But you can't do any better.  The
problem is that there is this hard core to the target function.

Boosting shows this situation is in a sense universal.  If you have
some arbitrary learning algorithm that supposedly works well, we'll
view it as a black box and either boost up its accuracy as much as we
like, or else we'll find a distribution D where that algorithm gets
error > 1/2 - gamma.

An easy case: algorithms that know when they don't know

Just to get a feel of a simple case, imagine our weak-learning
algorithm produces a hypothesis that on any given example x either
makes a prediction or says not sure.  Say it achieves the standard
PAC guarantee on the prediction region when it makes a prediction it
has error rate at most epsilon, and furthermore it says not sure at
most a 1-epsilon' fraction of the time it's trivial to produce a
hypothesis that always says not sure.  So, if we replaced not
sure with flipping a coin, the error rate would be at most
1/21-epsilon' + epsilon*epsilon' <= 1/2 - gamma for
gamma=epsilon'1/2-epsilon.  But we have more information since the
algorithm knows when it doesn't know.

Here we can do boosting by creating a decision list.  We first
run A on D to find h_1, and put as top rule in the DL.  We run A on D
subject to the constraint that h_1 says not sure i.e., when A asks
for an example, we repeatedly draw from D until we get one where h_1
says not sure and get h_2.  We then run A on D conditioned on both
h_1 and h_2 outputting not sure and get h_3.  Say our goal is to
achieve error 2*epsilon.  Then we can stop when the probability mass
on the unknown region reaches epsilon. Since each run chops off an epsilon'
fraction of the distribution remaining, after N runs, the probability
mass left is at most 1-epsilon'^N which we can set to epsilon.
Putting this together, only need to run O1/epsilon' log1/epsilon
times to get error down to 2*epsilon.

Basic idea here:  focus on data where previous hyp had trouble.  Force
next one to learn something *new*.


The general case: 2-sided error


Now let's go to the general case of boosting hypotheses that make
2-sided error.  We'll first talk about Schapire's original method the
one described in the textbook and then in the next class we'll talk
about Adaboost by Freund and Schapire that does this more
efficiently and gives a much more practical algorithm in the end.
Both have the same basic principle: feed in a series of distributions
or weighted datasets based on the hyps so far.  Do in a way that
forces alg to give us some *new* info.

To reduce notation, let's fix some weak error rate p.  Assume that we
have an algorithm A that over any distribution will produce a hyp of
error at most p with high probability.  In fact, let's for convenience
imagine that A always produces hypotheses of error rate *exactly* p
this will just simplify notation....   Say we want to boost it up a
bit, which we can then apply recursively.

We start by running A on the original distribution D and getting a
hypothesis h_1 of error rate at most p.  Now we want a new distribution.

One try: Filter D to only let through examples where h_1 predicts
incorrectly and try to learn over that.  This DOESN'T work.  Why?

Instead: we filter to create a distribution where h_1 behaves like random
guessing.  Specifically, let S_C be the set of examples on
which h_1 predicts correctly and S_I be the set on which h_1
predicts incorrectly.  What we want is a distribution D_2 where
S_C and S_I both have equal weight, but besides that is just like
D in that Pr_{D_2}x | x in S_C = Pr_{D}x | x in S_C
and the same for S_I.  For example, we can construct D_2 by
flipping a coin and if heads we wait until we see an
example where h_1 is correct, and if tails we wait until we
see one where h_1 is incorrect.  Or we can draw examples from D
and place them into two queues, one for S_C and one for S_I, and
then to get an example from D_2 we randomly choose a queue to select
from.

Let's write D_2[x] as a function of D_1[x] this is the probability
associated with x, or the density function if we're in a continuous
space.  To create D_2 we reduced the probability on S_C from 1-p to
0.5, so if x in S_C then D_2[x] = 0.5/1-pD[x].  We increased the
probability on S_I from p to 0.5 so if x in S_I then D_2[x] =
0.5/pD[x].

Now we get a hypothesis h_2 with error p on D_2.

Finally, we filter D only allowing examples x where h_1x != h_2x.
We then get hypothesis h_3 with error p on this distribution D_3.

Then we put the three together by taking majority vote.  Or, can think
of it this way: if h_1x=h_2x, then go with that, else go with h_3.

What is the best we could reasonably hope for?  Suppose h_1, h_2, h_3
were all independent predictors of error rate p.  Then the error rate
of the majority vote would be p^3 + 3p^21-p = 3p^2 - 2p^3.  E.g., if
p=1/4 then this drops to 5/32.  We will show the above scheme in fact
meets this bound exactly.  Then we can apply recursively to drive the
error down even further.


Analysis of this scheme
---------------------------
What's the accuracy of the new hypothesis?

Easiest way is to draw a picture.  Divide space into 4 regions: S_CC where
both h1 and h2 are correct, S_CI where h1 is correct and h2 is
incorrect, S_IC which is the reverse, and S_II where both are
incorrect.  Let's use p_CC, p_CI, p_IC, p_II as their respective
probabilities under D.

We predict correctly on S_CC, incorrectly on S_II and get 1-p fraction
correct on S_CI U S_IC.  So, our error rate is pp_CI + p_IC + p_II.

Let's define alpha = D_2[S_CI].
              So, p_CI = 21-palpha.
By defn of h2, D_2[S_II] = p-alpha.
              So, p_II = 2pp-alpha.
By construction of D_2, D_2[S_IC] = 1/2 - p-alpha.
              So, p_IC = 2p1/2 - p-alpha.

Putting this all together, our error rate is:

        p21-palpha + 2p1/2 - p + alpha + 2pp-alpha

      = 3p^2 - 2p^3.    QED


So, what the reweighting is doing is in a sense forcing the hyps to be
as useful as if they were independent.

==============================================

If we rewrite p as p = 1/2 - gamma so gamma is the edge over random
guessing we get a new error of 1/2 - gamma[3/2 - 2*gamma^2].  so you
can see the new edge is bigger

Now, if we want to drive the error down to epsilon we can do this
recursively, creating a ternary tree.  Let's look at how large a tree
this requires.  Will just do a rough calculation since will soon look
at a more efficient method next time.  First, for gamma < 1/4,
plugging into the above we get that at each iteration new-gamma >=
old-gamma*1 + 3/8.  So, this means that to reach error rate 1/4 we
just need Olog 1/gamma levels of recursion.

Now, once our error rate p is < 1/4, we can use the fact that after each
iteration, we get error rate at most 3p^2.  error rate after k
iterations at most 3^{2^k-1}*1/4^{2^k} < 3/4^{2^k}.  So, to get
error rate down to epsilon only need Ologlog1/epsilon more iterations.

So, the depth of the tree is Olog1/gamma + loglog1/epsilon.

This means the *size* of the tree 3^depth is poly1/gamma, log1/epsilon.

Lastly, filtering blows up sample size by additional O1/epsilon factor.

		15-859B Machine Learning Theory            02/05/14

* Boosting, contd:  Adaboost
========================================================================
Basic setup:

  Suppose we have an algorithm A that claims on every distribution to
  be able to get error at most p = 1/2 - gamma.  let's ignore the
  delta parameter. How can we use this as a black box to get error
  epsilon?

  Or, as a practical matter: say we have a learning algorithm that's
  good at finding rules-of-thumb.  How can we use it to produce a
  really good classifier? Or output a challenge dataset where any
  progress will help us do better?

Last time we looked at one method for reducing error Rob Schapire's
original approach.  This involved calling A 3 times on specially
reweighted distributions and taking majority vote.  If hypotheses
produced by A have error p=1/2 - gamma, then the result has error
3p^2 - 2p^3 = 1/2 - gamma[3/2 - 2*gamma^2].  so the new gamma is bigger

We then calculated the depth of tree needed to get to error epsilon,
which was Olog1/gamma + loglog1/epsilon.

So, the *size* of tree needed 3^depth is poly1/gamma, log1/epsilon.

==============================================

Adaboost idea: Instead of doing majorities of majorities, let's just
keep repeating step 2 of the previous scheme, each time reweighting
the examples so that the previous hypothesis gets error exactly 1/2.
Then take a big vote of all the hypotheses, weighted in some way by
how good they were on the distributions they came from.

E.g., a typical way this might work is say the initial data is 80%
negative.  So the first hypothesis h1 might be all negative and we
would then reweight so the data is 50/50.  Then the next hypothesis
might be something simple, such as that some variable xi is correlated
with the target, and we would reweight so that xi is now 50/50, and so
on. Not obvious this kind of thing will work since maybe you could get
into a cycle after reweighting so that h3 is 50/50, the algorithm
goes back and gives us h1! but it will come out of the proof.

What could we hope for?  Suppose we want to get error epsilon, and
algorithm A always gave us hypotheses of error 1/2 - gamma where the
errors were *independent*.  How many calls would we need so that the
majority vote had error epsilon?  I.e., if we pick a random example,
we want at most an epsilon probability of the vote being wrong.  This
is like flipping a coin of bias 1/2 - gamma and we want at most an
epsilon chance of more heads than tails.  Hoeffding bounds say that
it suffices for the number of flips T to satisfy e^{-2*T*gamma^2} = epsilon,
or T = 1/2*gamma^2*ln1/epsilon.

We are going to be able to achieve this, even though A is not
necessarily so nice.  In fact, as a byproduct, this argument actually
gives a *proof* of this case of Hoeffding bounds since giving
independent errors is one option for A.

One more point: the algorithm will in fact look a lot like the
randomized weighted majority algorithm, except the examples are
playing the role of the experts, the weak hypotheses are playing the
role of the examples, and right is wrong, don't worry - we'll figure it
out after we see the algorithm!.

Adaboost
--------
0. Draw large sample of size n that will be sufficient by Occam/VC arguments.

1. Start with weight w_i = 1 on each example x_i.
   The associated prob dist D has Px_i = w_i/W, where W = sumw_i.

2. For t=1 to T do:

        Feed D to weak algorithm, get back hypothesis h_t.   [Draw picture]

	Let beta_t = error rate/1 - error rate of h_t on D

        Now update D:  Multiply w_i by beta_t if h_tx_i is correct.

        notice: h_t now has 50% error on the new distribution

3. Final hypothesis: let alpha_t = ln1/beta_t.  Output a majority
   vote weighted by the alphas.  I.e., hx = signsum_t alpha_t * h_tx
   if we view labels as +/-1.


Claim: training errorhl < e^{-2*sum_t[ gamma_t^2 ]}

   where 1/2 - gamma_t = error rate of h_t on D_t.

So, if each time we have error at most 1/2 - gamma, we run it T times,
we get e^{-2T gamma^2}.  For error epsilon, use T=O1/gamma^2 log1/eps
Notice similarity to Hoeffding formula


ANALYSIS
========

To simplify things, let's assume all gamma_t's are the same.  Call
it gamma.  Then beta is fixed, and the final hypothesis is just a
straight majority vote over the h_t's.

Some notation:
     error = 1/2 - gamma  error of each weak hypothesis
     beta = error/1-error = 1/2 - gamma/1/2 + gamma
     T = number of steps we run this procedure

Let's now analyze as in randomized WM, by putting upper and lower bounds
on the final weight.  For the upper bound, suppose we currently have a total
weight of W.  Since a 1-error fraction of W gets multiplied by beta,
after this step that portion has weight only error*W, so the total
weight is 2*error*W.  Since the total weight starts at n, this means
that:

   W_final <= n*2*error^T

Now, let's look at the lower bound.  To do the lower bound, notice
that any example on which our majority vote makes a mistake must
have weight at least beta^{T/2}, since if our majority vote is wrong
then we could have multiplied it by beta *at most* T/2 times.  So, if
in the end our error rate is epsilon so we make a mistake on epsilon*n
points, then

	W_final >= beta^{T/2} * epsilon * n

Combining our upper and lower bounds gives us:

        epsilon <= [4*error^2 / beta]^{T/2}

                 = [4*1/2 - gamma*1/2 + gamma]^{T/2}

                 = [1 - 4*gamma^2]^{T/2}.

Now we use our favorite inequality: 1-x <= e^{-x}

        epsilon <= e^{-2T*gamma^2}.   QED

=======================
So, just to summarize, if we had T hypotheses of *independent* error
1/2 - gamma, then Hoeffding bounds give us this bound on the error
rate of their majority vote.  What we are able to do with Adaboost is
achieve this error with an arbitrary weak learning algorithm, that
just guarantees that to give error at most 1/2 - gamma on whatever
distribution it's given.

What about true error versus empirical error?  What we really have at
this point is a bound on empirical error.  To have a bound on true
error we need our sample to be large enough so that not only do we get
uniform convergence over the hypothesis space H used by A, but also
we get uniform convergence over majority votes of O1/gamma^2 *
log1/epsilon hypotheses in H.  To get a feel for this, let
MAJ_kH be the functions you can get by taking majorities of k
functions in H.  If there are H[m] ways of splitting m points using
functions in H, then there are at most {H[m] choose k} ways of
splitting functions using majorities.  So, the sample size bound just
needs to increase by a multiple of k.

Margin analysis
===============
Actually, one thing people noticed in practice is that if you keep
running Adaboost past this limit, you don't end up overfitting.
There's a nice way of looking at this in terms of L_1 margins.

Let's define g = alpha_1 h_1 + ... + alpha_T h_T, so our final
hypothesis hx is signgx.  Let's scale the alpha_t's so they sum
to 1.  Now, define the L_1 margin of g or h on an example x of label y
to be y*gx.  We're calling it the L_1 margin because we have
scaled g to have L_1 length equal to 1

If you look carefully at our analysis of adaboost, it ends up showing
not only that there can't be too many examples where the majority vote
is wrong negative margin but in fact there can't be too many where
the majority vote is barely right.  In fact if you keep running the
algorithm, the fraction of examples with margin < gamma will go to 0
because those examples have too high a weight compared to the upper
bound of 1 - 2*gamma^T.

What does this mean?  One thing about having margin gamma is that even
if T is huge, you can whp produce the exact same prediction that h
does by just viewing g as a probability distribution and sampling from
it k = 1/gamma^2*log1/epsilon times, and then taking majority vote
over the sample.  So, as long as we have enough data so that these
small majority votes aren't overfitting, then h can't be overfitting
by much either.  Let's do this more formally.  Let h' be the
randomized prediction function that given a new example x predicts the
majority vote over k random draws from distribution g.  Then the true
error rates must satisfy errh' >= errh/2 since if hx is
incorrect, this means that each random draw from g has at least a 50%
chance of giving the wrong answer on x, so h' has at least a 50%
chance of being incorrect.  But we argued that the empirical error of
h' is low [because if h has margin gamma on x then whp h'x=hx].
Furthermore we have enough data so that whp *all* small majority-vote
functions have empirical error close to their true error, which
implies the empirical error of h' is close to its true error.
Therefore the true error of h must be low too.

		15-859B Machine Learning Theory            02/10/14

* Tighter sample complexity bounds: Rademacher bounds
* A great tool: McDiarmid's inequality
===========================================================================
Boosting recap - view as dot-game: we put prob distrib on columns, and
then adversary gives a row with dots in at most 40% of the entries by
probability mass.  What we want is to adjust the probability
distribution to ensure than nearly all the *columns* have dots in less
than half the entries.

===========================================================================
Let's recap our VC-dimension bounds:  Let C[m] = max # ways of
splitting m examples using concepts in C.

THEOREM 1: For any class C, distrib D, if the number of examples seen
m satisfies: m > 2/epsilon[lg2C[2m] + log_21/delta], then
with prob 1-delta, all bad error > epsilon hypotheses in C are
inconsistent with data.

THEOREM 2: For any class C, distrib D, if the number of examples seen
m satisfies: m > 8/epsilon^2[ln2C[2m] + ln1/delta]
then with prob 1-delta, all h in C have |err_Dh-err_Sh| < epsilon.

SAUER'S LEMMA: C[m] < m^d, where d = VCdimC.  So can use Sauer's
lemma to convert to bounds in terms of VC dimension.  Resulting bound
is O1/epsilon^2[d*ln1/epsilon + ln1/delta].


---------------------------------------------------------------------
Motivation and plan
===================

These bounds are nice but have two drawbacks that we'd like to
address:

1. computability/estimability: say we have a hypothesis class C
   that we don't understand very well.  It might be hard to compute or
   estimate C[m], or even |C[S]| for our sample S.

2. tightness.  Our bounds have two sources of loss.  One is that
   we did a union bound over the splittings of the double-sample S,
   which is overly pessimistic if many of the splittings are very
   similar to each other.  A second is that we did worst-case over S,
   whereas we would rather do expected case over S, or even just have a
   bound that depends on our actual training set.  We will be able to
   address both of these, at least in the context of THM 2.

In particular, we will show the following remarkable fact.  Suppose
you replaced the true labels with random coin flips and then found the
lowest-empirical error function in the class for these.  Imagine we
have a great optimizer that, given any set of labels, will find the h
in C that minimizes empirical error with respect to those labels.
Say it gives error 45%.  That means that we are overfitting by 5% wrt
the coin flip function since every hypothesis has true error 1/2 wrt
that.  Take that gap 5%, double it, and the result plus some
low-order term is an upper bound on how much any h in C is
overfitting wrt the true target f.  This is pretty remarkable since up
to low-order terms we're within a factor of 2 of the best possible
target-independent bound since we do indeed overfit by 5% wrt the
coin-flip function.  And there do exist cases where you indeed have
to lose the factor of 2.  E.g., consider the class of all boolean
functions over {0,1}^n, with a target that is all negative describe.

One caveat: This is along the THEOREM 2 style - e.g., best you could
hope for is overfitting of 1/sqrtm.  In the realizable case where
you just care about the true error of functions whose empirical error
is zero, these bounds could be quite a bit worse, since then you get
overfitting on the order of complexity term/m.

Note: rather than writing m as a function of epsilon, let's write
epsilon as a function of m.  In particular, we can write Thm 2 as: For
any class C and distribution D, whp all h in C satisfy
    err_Dh <= err_Sh + sqrt{8ln2C[2m]/delta / m}.
And we bound in the other direction as well, but let's just focus on
this direction - i.e., how much can we be overfitting the sample.

----------------------------------------------------------------------

Rademacher averages
===================
For a given set of data S = {x_1, ..., x_m} and class of functions F,
define the empirical Rademacher complexity of F as:

    R_SF = E_sigma [ max_{h in F} 1/msum_i sigma_i * hx_i ]

where sigma = sigma_1, ..., sigma_m is a random {-1,1} labeling.

I.e., if you pick a random labeling of the points in S, on average how
well correlated is the most-correlated h in F to it?  Note: h:X->{-1,1},
so sigma_i * hx_i = 1 if they agree and -1 if they disagree.  Note
that correlation = agreement - disagreement so error 45% means
correlation of 10%.

We then define the distributional Rademacher complexity of F as:

    R_DF = E_S R_SF.


We will then prove the following theorem:

THEOREM 3: For any class C, distrib D, if we see m examples then with
probability at least 1-delta every h in C satisfies

    err_Dh <= err_Sh + R_DC + sqrtln2/delta/2m.
             <= err_Sh + R_SC + 3*sqrtln2/delta/2m.

----------------------------------------------------------------------

Relating Rademacher and VC: We can see that this is never much worse
than our VC bounds.  In particular, let's consider how big can R_SC
be?  If you fix some h and then pick a random labeling, Hoeffding
bounds say the probability the correlation is more than 2epsilon is at
most e^{-2*m*epsilon^2}. So setting this to delta/C[m] and doing a
union bound, we have at most a delta chance that any of the splittings
in F have correlation more than 2*sqrtlnC[m]/delta/2m, so the
expected max correlation R_SC can't be much higher than that.  On
the other hand, it could be a lot lower if many of the splittings are
very similar to each other.  OK, now on to the proof of Theorem 3...

----------------------------------------------------------------------

First, a useful tool we will use is McDiarmid's inequality.
This generalizes Hoeffding bounds to the case where, rather than
considering the *average* of a set of independent RVs, we are
considering some other function of them.  Specifically,

McDiarmid's inequality
======================
Say x_1, ..., x_m are independent RVs, and phix_1,...,x_m is some
real-valued function.  Assume that phi satisfies the Lipschitz
condition that if x_i is changed, phi can change by at most c_i.  Then
McDiarmid's inequality states that:

      Pr[phix > E[phix] + epsilon] <= e^{-2*epsilon^2 / sum_i c_i^2}

so if all c_i <= 1/m like if phi = average and x_i in {0,1}, we get:

      Pr[phix > E[phix] + epsilon] <= e^{-2*epsilon^2 * m}

just like Hoeffding.

Proof of THEOREM 3
==================
STEP 1: The first step of the proof is to simplify the quantity we
care about.  Specifically, let's define
    MAXGAPS = max_{h in C} [err_Dh - err_Sh].

We want to show that with probability at least 1-delta, MAXGAPS is
at most some epsilon.

As a first step, we can use McDiarmid to say that whp, MAXGAPS will
be close to its expectation.  In particular, the examples x_j are
independent RVs and MAXGAP can change by at most 1/m if any individual
x_j in S is replaced because the gap for any specific h can change by
at most 1/m.  So, using this as our phi, with probability at least
1 - delta/2, we get:
     MAXGAPS <= E_S [MAXGAPS] + sqrtln2/delta/2m.

So, to prove the first main line of THEOREM 3, we just need to show
that  E_S[ MAXGAPS ] <= R_DC.

In fact, the second line of the theorem follows immediately from the
first line plus an application of McDiarmid to the random variable
R_SC [how much can changing a training example change R_SC?].  So,
really we just need to prove the first line.

STEP 2: The next step is to do a double-sample argument just like we
did with VC-dimension.

Specifically, let's rewrite err_Dh as E_{S'} [err_{S'}h], where S'
is a new set of m points drawn from D this is the ghost sample.
So, we can rewrite E_S[MAXGAPS] as:

    E_S [ max_{h in C} [ E_{S'} [ err_{S'}h - err_{S}h ] ] ]

 <= E_{S,S'} [ max_{h in C} [ err_{S'}h - err_{S}h ] ]
          i.e., get to pick h after seeing both S *and* S'

If we let S = {x_1,...,x_m} and let S' = {x_1', ..., x_m'} then we can
rewrite this as:

    E_{S,S'} [ max_{h in C} [ sum_i [err_{x_i'}h - err_{x_i}h]/m] ]

where I'm using err_{x}h to denote the loss of h on x 1 if h makes
a mistake and 0 if h gets it right.

Now, as in the VC proof, let's imagine that for each index i, we flip
a coin to decide whether to swap x_i and x_i' or not before taking the
max.  This doesn't affect the expectation since everything is iid.
So, letting sigma_i in {-1,1} at random, we can rewrite our quantity as:

    E_{S,S',sigma}[max_{h in C}[sum_i sigma_i[err_{x_i'}h - err_{x_i}h]/m]]


 <= E_{S',sigma} [ max_{h in C} [sum_i sigma_i * err_{x_i'}h/m] ] -
    E_{S,sigma}  [ min_{h in C} [sum_i sigma_i * err_{x_i}h/m] ]
    i.e., gap is only larger if allow the two h's to differ

  = 2*E_{S,sigma} [ max_{h in C} [sum_i sigma_i * err_{x_i}h/m] ]
    by symmetry, since sigma_i is random {-1,1}

Now, we're just about done.  The quantity here is a lot like the
Rademacher complexity of C except instead of looking at the
dot-product <sigma,h> viewing each as a vector of m entries, we are
looking at <sigma, lossh> where lossh is the vector of losses of
h.  In addition we have an extra factor of 2.

To translate, suppose that in the definition of Rademacher complexity
we replace <sigma,h> with <sigma * f, h> where * is component-wise
multiplication and f is the target function.  That is, instead of
viewing sigma as a random labeling, we view it as a random
perturbation of the target.  Notice that sigma * f has the same
distribution as sigma, so this doesn't change the definition.  Now,
<sigma * f, h> = <sigma, f * h>.  This is nice because f * h is the
vector whose entry i is 1 if hx_i=fx_i and equals -1 if hx_i !=
fx_i.  In other words, f*hx = 1 - 2err_xh.

So, R_DC = E_{S,sigma} [max_{h in C} [sum_i sigma_i[1-2err_{x_i}h]/m]]

           = 2*E_{S,sigma} [ max_{h in C} [sum_i sigma_i * err_{x_i}h/m]]
as we wanted.

So, this gives us what we want.
-----------------------------------------------------------------------

		15-859B Machine Learning Theory            02/17/14

* Better MB->Batch conversion
* SVMs
* L_2 Margin bounds
=====================================================================

We've seen several algorithms for learning linear separators Winnow,
Perceptron.  Today will talk about SVMs and more about sample-size
bounds for learning over iid data.

Recap of facts so far
=====================
1. VC-dim of linear separators in n-dim space is n+1.  So this says
that O1/epsilon[n*log1/epsilon+log1/delta] examples are
sufficient for learning.

2. But, we've seen that if there's a large margin, can get away with less.
Let's assume target is w^* . x > 0, and has zero error. |w^*| = 1,
and all ||x|| <=1.  Given a sample S, define the L_2 margin to be:
      gamma = min_{x in S} |w^* . x|

In this case, the Perceptron algorithm makes at most M = 1/gamma^2
mistakes.  Can then convert this into a sample-size bound for iid
data.

Topic 1: Better MB=>Batch conversion
====================================
Let's do the improved online->batch conversion formally, since we
didn't quite do it earlier in class.

Theorem: If have conservative alg with mistake-bound M, can use to get
PAC sample-complexity O1/epsilon[M + log1/delta]

Proof: To do this, we will split data into a ``training set'' S_1 of size
  max[4M/epsilon, 16/epsilon*ln1/delta]
and a ``test set'' S_2 of size
  32/epsilon*lnM/delta
We will run the algorithm on S_1 and test all hypotheses produced on S_2.

Claim 1: w.h.p., at least one hyp produced on S_1 has error < epsilon/2.
Proof formally, use martingales:
 - If all are >= epsilon/2 then the expected number of mistakes >= 2M.
 - By Chernoff, Pr[# mistakes <= M] <= e^{-expect/8} <= delta.
 -  View as game: after M mistakes, alg forced to reveal target.  If
    alg keeps giving bad hyps, then whp will be forced to do it.

Claim 2: w.h.p., best one on S_2 has error < epsilon.
Proof: Suffices to show that good one is likely to look better
than 3*epsilon/4, and all with true error > epsilon are likely to look
worse than 3*epsilon/4.  Just apply Chernoff again to the set of M
hypotheses as in your homework.

Note that this could be better or worse than the dimension bound.

In fact, can show that whp *any* large-margin separator you can
find will generalize well from roughly this much data.  So, this
motivates why SVMs find large margin separators.

Support-Vector Machines
=======================

Support vector machines do convex optimization to find the maximum
margin separator, and more generally to optimize a given tradeoff
between margin and hinge-loss.  Let's first do the easier case, where
we assume data is linearly separable and we want the separator of
maximum margin.  Then we could write that as: minimize |w|^2 subject
to the constraint that fx*w.x >= 1 for all examples x in our
training set fx is the label of x.  This is a convex optimization
problem, so we can do it.  Equivalently we could fix |w|^2 <= 1 and
maximize gamma s.t. lxw.x >= gamma, but people like to do it this
way, for reasons that will make more sense in a minute.  Note that if
we set the RHS to 1, then 1/|w| is the margin and so |w|^2 = 1/gamma^2.

More generally, we want a tradeoff betwen margin and hinge-loss, so
what SVMs really do is C is a given constant:

    minimize: |w|^2 + C sum_{x_i in S} epsilon_i
  subject to: fx_iw cdot x_i >= 1 - epsilon_i, for all x_i in S.
              and epsilon_i >= 0 for all i.

These epsilon_i variables are called slack variables.

[also write down objective function divided by |S| since will be
easier conceptually for motivation below]

Here is the motivation.  What we *really* want is to minimize the true
error errh, but what we observe is our empirical error err_Sh.
So, let's split errh into two parts: 1 errh - err_Sh, which
is the amount we're overfitting, and 2 err_Sh.  One bound on part
1 is approximately 1/gamma^2/|S|, if err_Sh is small since our
sample complexity bound is approximately |S| = 1/gamma^21/epsilon
which means epsilon = 1/gamma^2/|S|.
So, this is 1/|S| times the first part of the objective function.  The
second part of the optimization for C=1 is our total hinge-loss,
summed over all the examples.  Dividing by |S| we get our average
hinge-loss, which is an upper bound on err_Sh.  So, an upper bound
on 2 is 1/|S| times the second part of the objective function.
So, the two parts of the objective function are upper bounds on the
two quantities we care about: overfitting and empirical error.   And
if you feel your upper bound on 1 is too loose, you might want to
set C to be larger.


More about margins
==================

- We've seen that having a large margin is a good thing because then
  the perceptron algorithm will behave well.  It turns out another
  thing we can say is that whp, *any* separator with a large margin
  over the data will have low error.  This provides more motivation
  for finding a large-margin separator.

Sample complexity analysis
==========================
The sample complexity analysis is done in two steps.

First thing to show: what is the maximum number of points in the unit
ball that can be split in all possible ways by a separator of margin
at least gamma?  a.k.a., gamma fat-shattering dimension.  Ans:
O1/gamma^2.  Can anyone see a simple proof?

Proof: Consider the perceptron algorithm.  Suppose the gamma
fat-shattering dimension is d.  Then we can force perceptron to make d
mistakes, and yet still have a separator w^* of margin gamma.  But we
know the number of mistakes is at most 1/gamma^2.  So, that's it.


Second part: now want to apply this to get a sample-complexity bound.
Sauer's lemma still applies [to bound the number of ways to split a
set of m points by margin gamma, as a function of the fat-shattering
dimension] so seems like analysis we used for VC-dimension should just
go right through, but it's actually quite not so easy.  Plus there's
one technical fact we'll need.  Let's do the analysis and will just
give a citation for the technical fact we need.

Analysis: Draw 2m points from D.  Want to show it is unlikely there
exists a separator that gets first half correct by margin gamma, but
has more than epsilon*m mistakes on the 2nd half.  This then implies the
conclusion we want, by same reasoning as when we argued the VC bounds.

As in VC proof, will show that for *any* sets S1, S2 of size m each,
whp this is true over randomization of pairs {x_i, x_i'} into T1, T2.
Let S = S1 union S2.  In VC argument, we said: fix some h that
makes at least epsilon*m mistakes.  Said that Proball mistakes are in
T2 is at most 2^{-epsilon*m}.  Then applied union bound over all
labelings of data using h in C.  For us, it's tempting to say: let's
count the number of separators of S with margin gamma over all of S.
But this might be undercounting since what about separators where h
only has margin gamma on T1?  Instead, we'll do the following more
complicated thing.  Let's group the separators together.  Define hx
= <h,x> but truncated at +/- gamma.  Let dist_Sh1,h2 to be max_{x in
S}|h1x - h2x|.  We want a gamma/2-cover: a set H of separators
such that every other separator is within gamma/2 of some separator in
H.  Claim is: there exists an H that is not too large, as a function
of fat-shattering dimension [Alon et al].  Can view this as a
souped-up version of Sauer's lemma.  Roughly you get |H| ~
m/gamma^2^logm/gamma^2.  Now, for these functions, define
correct as correct by margin at least gamma/2 and define mistake
as mistake OR correct by less than gamma/2.  Our standard VC
argument shows that so long as m is large compared to
1/epsilon*log|H|/delta, whp, none of these will get T1 all
correct, and yet make > epsilon*m mistakes on T2.  This then implies
by defn of H that whp *no* separator gets T1 correct by margin >=
gamma and has > epsilon*m real mistakes on T2.

log|H| is approximately log^2m/gamma^2, so in the end you get a
bound of m = O1/epsilon [1/gamma^2 log^21/gamma*epsilon + log1/delta].

Notice this is almost as good as the Perceptron bound.

Luckiness functions
===================
Basic idea of margins was in essense to view some separators as
simpler than others, using margin as the notion of simple.  What
makes this different from our Occam bounds, is that the notion of
simple depends on the data.  Basically, we have a data-dependent
ordering of functions such that if we're lucky and the the target has
low complexity in this ordering, then we don't need much training
data.  More generally, things like this are called luckiness
functions.  If a function is a legal notion of luckiness
basically, the ordering depends only on the data points and not their
labels, and not too many splits of data with small complexity then
you can apply sample complexity bounds.
		15-859B Machine Learning Theory       03/05/14

* Characterizing what's learnable in SQ model via Fourier analysis
========================================================================
Statistical Query model recap
-----------------------------

No noise. Algorithm asks ``what is the probability a labeled example will
have property chi?  Please tell me up to additive error tau.''

Formally, chi: X x {0,1} --> {0,1} must be poly-time computable. tau > 1/poly.
Asking for Pr_Dchix,cx=1.

Examples:
  - Can ask for error rate of current hypothesis h what is chix,y?

  - Can ask for Prx_1=x_2 and label = +.

can also handle chi with range [0,1]

May repeat this polynomially many times, and in the end the algorithm
must output a hypothesis with error < epsilon no delta in this
model.

THEOREM: If can learn C in SQ model, then can learn in PAC with
random noise model.

Characterization of SQs using Fourier analysis
==============================================

SQ-dimension
============
- We will say that functions f and g are uncorrelated if
      Pr_D [fx=gx] = 1/2.

We will define the SQ-dimension of a class C under distribution D to
be the size of the largest set S of nearly uncorrelated functions in
C.  Specifically, the largest S such that for all f,g in S,
    | Pr_D [fx=gx] - 1/2 | < 1/|S|.

Theorem 1: If SQdim_DC = polyn then you *can* weak-learn C over D by SQ
algorithms.

Theorem 2: if SQdim_DC > polyn then you *can't* weak-learn C over D by
SQ algorithms.

Example: parity
- Let D be the uniform distribution over {0,1}^n.
- Fact: any two parity functions are uncorrelated over the uniform distrib.
- So, C = {all 2^n parity functions over {0,1}^n} is not SQ-learnable
  over the uniform distribution.

Example: parity_log
- Let C_log = { parity functions of size logn }.
- |C_log| = n^log n > polyn.  So, this is also not SQ-learnable.

- This means that the class of poly-size DNF and the class of
  poly-size decision trees are not SQ-learnable.  Why?  Because these
  contain C_log.

Can anyone think of a non-SQ alg to learn parity?

Learnability of parity with noise is big open crypto and coding-theory
problem.

Theorem #1 is the simpler of the two.

Proof of Theorem 1:

   Let d = SQdim_DC.  The algorithm will be specific for the
   distribution D.  In particular, we store in advance a maximal set H
   of functions such that for all f,g in H, |Pr[fx != gx] - 1/2| <
   1/d+1.  So, |H| <= d.

   To learn, ask for Pr[cx = hx] for each h in H, with
   tau=0.25/d+1.  We know there must be some h such that the correct
   answer differs from 1/2 by at least 1/d+1 = 4*tau, else H wouldn't be
   maximal.  So, just keep asking until we find one whose response
   differs from 1/2 by at least 3*tau, which means the *true*
   answer for that h differs from 1/2 by at least 2*tau.  So,
   output either h or noth as appropriate.

   Note: for this to imply PAC learning for all D, need small SQ-dim
   for all D and also need to be able to construct hyps in poly time.


Now, let's go to Theorem 2, which is the more interesting one.  To
make things simpler, let's change nearly uncorrelated to
uncorrelated.  That is, we will show that if C contains a super-poly
size set of uncorrelated functions over D, then C is not even weakly
SQ-learnable over D.


Fourier analysis of finite functions
-------------------------------------
Not inherently complicated.  But it *is* subtle conceptually.  I think it's
neat, so *please* stop me when it gets confusing....

First of all, let's think of positive as +1 and negative as -1, so a
boolean concept is a function from {0,1}^n to {-1, +1}.

Think of a function f as a vector of 2^n elements, one for each
input.  We'll associate with f the vector:

sqrtPr000 * f000, sqrtPr001 * f001, ..., sqrtPr111 * f111

In other words, this is the truth table of f, but weighted by sqrtPrx.

What is the L^2 length of f as a vector?  <f,f> = 1.

What is <f,g>?
<f,g> = sum_x Prxfxgx = E_D[fxgx] = Prfx=gx - Prfx!=gx.

Let's call this the correlation of f and g with respect to distrib D.
<f,g> = 0 means that f and g are uncorrelated.  They are orthogonal as
vectors.

So, this is a nice way of looking at a set of functions.  Each
function is a vector in this 2^n-dimensional space, and the dot
product between two vectors tells us how correlated they are.

Fourier analysis is just a way of saying that we want to talk about
what happens when you make a change of basis.

An orthonormal basis is a set of orthogonal unit vectors that span
the space.  For instance, in 2-d, let x' be the unit vector in the
x direction and y' be the unit vector in the y direction.  Then a
vector v = 3,2 is 3*x' + 2*y'.  Say we have two other orthogonal
unit vectors a and b. Then could also write v in terms of a and b as:
	v = <v,a>a + <v,b>b
This is called a change of basis.

In our 2^n dimensional space, an orthonormal basis is a set of 2^n
orthogonal unit vectors.  For instance, if D is the uniform
distribution, then the parity functions are one possible orthonormal basis.

Lets fix one: phi_1, phi_2, ..., phi_{2^n}.

Given a vector f, let f_i be the ith entry in the standard basis.
I.e., f_i = fi*sqrtPri.

then hat{f}_i = <f,phi_i> is the ith entry in the phi basis.

For instance, we could write the vector f as: f = sum_i hat{f}_i * phi_i

The hat{f}_i are called the fourier coefficients of f in the phi basis.

Since, as a vector, we have f = sum_i hat{f}_i * phi_i, this also
means that as functions,
	fx = sum_i hat{f}_i phi_ix

The reason is that the left-hand-side is the xth coordinate of f,
divided by sqrtPrx.  So, all we're saying is that if one vector is
the sum of a bunch of other vectors, then the xth coordinate of the
vector is the sum of the xth coordinates of the other vectors.

So, nothing fancy so far, but here's one neat thing that comes out of
the point of view we're using:  Since f is a unit vector, the sum of
the squares of its coefficients is equal to 1.  So,

	sum_i hat{f}_i^2 = 1.

	This is called Parseval's identity

One thing this implies is: at most t^2 of the hat{f}_i can be greater
than 1/t.

In other words, any boolean function f can be weakly correlated with
at most a polynomial number of the phi's.  More generally if we have
some set S of pairwise uncorrelated functions, then f can be weakly
correlated with at most a polynomial number of functions in S since
we can extend this set arbitrarily into an orthonormal basis.

Here is the point:  Suppose we ask a query what is the correlation of
the target with my hypothesis h? with some tau = 1/poly.  Then if the
target function is chosen randomly from some superpolynomial-sized set
of uncorrelated functions like parity functions then w.h.p. the
correct answer is infinitesimally small, so a legal response is 0.
each question throws out only a poly number of possibilities.

Or, to think about what this means going back to the PAC-style
setting:  if you have a fixed set of data and you're doing
hill-climbing, then each time you do a check on your current error,
whp the correct answer is infinitesimally close to 1/2, and all the
variation is due to the variation in the data sample.  It will take
more than poly number of steps to stumble on a good query.

It turns out that ANY Stat query can be basically viewed in this way.



Proof:

Step 1: Say the set S of orthogonal functions is phi_1, ..., phi_m.
Let's extend this to an orthonormal basis arbitrarily
	phi_1, ..., phi_m,..., phi_{2^n}
only the first m of these are functions in our concept class

Step 2: chix,l is a function from {0,1}^n x {-1,1} to [-1,1].
Might as well extend range to [-1,1].  So we can think of chi as a
vector but in 2^{n+1} dimensions.  To use fourier analysis, we need to
extend our basis to this higher-dimensional space.  Can do it like this:

	* define distrib D' = D x uniform on {-1, +1}

	* Define phi_ix,l = phi_ix.

          still orthogonal:
          Pr_D'[phi_ix,l = phi_jx,l]  =  Pr_D[phi_ix=phi_jx]  =  1/2


	* Need 2^n more basis functions.  Let's define

		h_ix,l = phi_ix * l.  Need to verify this is OK:

	  - check that h_i and h_j are orthogonal for i != j

	  - check that h_i and phi_j are orthogonal

	    Pr[h_ix,l = phi_jx] = Pr[l*phi_ix = phi_jx]

	    even if i=j we get 1/2.


Step 3: Do a fourier decomposition of chi.

	chi = sum_i alpha_i*phi_i + sum_i beta_i*h_i

	     where sum_i alpha_i^2 + sum_i beta_i^2 = 1.

So, we can write the quantity we're asking about

	E_D[chix, cx]

		= E_D[ sum_i alpha_i*phi_ix + sum_i beta_i*h_ix,cx]

		= sum_i alpha_i*E_D[phi_ix] + sum_i beta_i*E_D[cxphi_ix]

The first term is some constant offset that depends on the query but
is independent of the target function.

What about the second term?  Well, since c = phi_target is one of the
phi's, and since they are orthogonal, that expectation is 0 except for
phi_target.  So, the second term is just beta_target.

And, since at most 1/tau^2 of the betas can be larger than tau, since
the target was chosen randomly from superpolynomial-sized set, this is
whp less than tau.  So, can whp respond with just the first part
that is independent of the target function.

That's it.

		15-859B Machine Learning Theory             03/17/14
* use of Fourier analysis for learning
* Learning via Membership queries I
* KM algorithm for finding large Fourier coefficients
=========================================================================
Recap SQ analysis
=================
- Fourier view of functions as vectors once we fix a distribution over data
- Showed that if target is picked randomly from a large set of
  orthogonal functions, then SQ alg is in trouble.
   - can view *any* SQ alg as basically proposing a unit vector and
     asking for correlation dot-product with target.
     Can break any SQ into one part that looks like this, and one
     part that depends only on data distribution

     [this part went by very fast at the end last time, so perhaps go through
     the argument again]

   - Then use the fact that in any orthogonal coordinate system, a
     unit vector can have at most t^2 coefficients that are >= 1/t.

   - This means that if target is picked from set S of orthogonal
     functions, Prdot-product >= 1/t <= t^2/|S|.

   - So, if > polyn orthogonal functions, then can't even weak-learn
     with poly # of queries, each of tolerance 1/poly.


Using Fourier analysis for learning
===================================
- useful tool for learning wrt uniform distribution. basis of parity fns

- esp useful with queries.  Will talk about an alg for *finding*
  large fourier coeffs over parity basis if can prod target f with
  inputs x of our own choosing.

Some general results
====================
Suppose phi_1x, phi_2x, ... is an orthonomal basis of boolean functions.
<phi_i,phi_j>=0 for all i!=j

	fx = sum_i hat{f}_i phi_ix

hat{f}_i = correlation of f with phi_i = <f, phi_i>.

Claim 1: if you can find non-negligable fourier coefficient then you
can weak-learn.
Proof: Just directly from defn of correlation. Use phi_i or its complement.

Now, suppose we can find most of the fourier coefficients.  Say we
can find a set S that captures all but epsilon of the hat{f}_i^2.
Let g = sum_{i in S} hat{f}_i phi_i note, this may not be a boolean
function.  Then, as vectors, we have |f-g|^2 = epsilon.

Claim 2: Pr[fx != signgx] <= epsilon.  So signg is a good apx to f.

Proof: f-g = ...,sqrt[Prx]fx-gx,... so |f-g|^2 = <f-g,f-g> =
E[fx-gx^2] = epsilon.  Notice that every x where signg is
wrong contributes at least 1.  So, the error of signg is at most
epsilon.

In fact, can see from above argument that we don't need to get the fourier
coeffs exactly.  If someone hands us S, we can estimate the coefficients
by looking at correlations, and get a good apx to g.  That's all we need.

Learning wrt uniform distrib
============================
Above general statements hold for generic setting.  Now, focus on
learning wrt uniform distribution.  Specific basis of parity
functions.  So, view like this: we have some unknown function f on n
inputs in a box.  Can see f on uniform random pts.  Maybe we're
allowed to query f on inputs of our choosing the Membership Query
model.  Goal, find g that approximates f in the sense that it gets
most of the domain correct.

Below: Kushilevitz-Mansour algorithm that using Membership Queries,
will find all i such that hat{f}_i^2 > tau in time poly n, 1/tau.
In the next class we will prove that any Decision Tree must have most
of its length in large fourier coefficients to get a poly-time
algorithm to learn decision trees with MQs wrt the uniform
distribution via Claim 2 above.

Learning with Membership queries
================================
So far we have focused on learning in a model where the
learning algorithm has no control over the examples it sees.  We are
now going to consider what happens if we allow a learning algorithm
to ask for labels on examples of its own construction.  These are called
Membership Queries MQs.  These are natural for learning problems
where the target function is some device that we are trying to
reverse-engineer.  One thing that makes MQs interesting is now there
is a wider space of things the algorithm can do.

[Terminology note: active learning generally corresponds to a setting
where you have a pool of unlabeled data and can only select among them.
MQs allow the algorithm to completely specify the example to be labeled.]

Can define the following models:

PAC + MQ: Can sample from D and ask MQs.   Goal: low error wrt D.

    Special case D=uniform on {0,1}^n.  Can view this is you have a
    black box that you can prod as you like and you want h that agrees
    with target on most of the domain.

MB + MQ: Mistake-bound setting with queries.  Pay $1 per mistake and
    pay $1 per query.   Also called the equivalence + membership
    query model.

Exact learning with MQ only: need to recover target exactly using only
    queries.  Pretty tough.  E.g., can't even do conjunctions why?.
    But you *can* do parity how?

Let's start with a simple algorithm.

Learning Monotone DNF in MB+MQ model
====================================
Ideas?
 * Start with hx = all-negative.
 * If predict negative on a positive example x:
   - walk x down to a minimal positive example go left to right along
      x, flipping 1's to 0's so long as they keep the example positive.
   -  The conjunction of the variables in x must be a term of c.  So put
      it into h.
 * Since we maintain that all terms of h are also in c, we don't make
   any mistakes on negatives.

Total number of mistakes is at most # of terms in target.  Number of
queries at most n per term.

OK, now let's go to the Kushilevitz-Mansour algorithm.

Kushilevitz-Mansour Goldreich-Levin algorithm:
===============================================
Let's index parity functions by their indicator vectors.
Our goal is to find all hat{f}_v such that hat{f}_v^2 > tau.

Say S is the set of all indicator vectors.  So the sum, over v in S,
of the hat{f}_v^2 equals 1.  Suppose we split S into
	S_0 = {v: v begins with 0}
	S_1 = {v: v begins with 1}
and suppose for each of these we could ask for the sum of squares of
the hat{f}_v in that set.  And, suppose we could do this recursively.
E.g., ask for sum of squares in:
	S_00 = {v: v begins with 00}
	S_01 = {v: v begins with 01}

Then what?  Then we could build up a tree, splitting each node whose
answer is > tau, and ignoring those < tau.
 - max width of tree is 2/tau.
 - Just keep going to leaves at depth n.
 => Only On/tau questions to ask.

So, all boils down to: how can we ask for the sum of squares of the
hat{f}_v's inside these sets?  In general, our goal is now to
estimate, for some string alpha of 0s and 1s, the sum of the squares
of the hat{f}_v's for all v that begin with alpha.

Note: we won't find the sum exactly.  We'll find an estimate of the
sum.  But that's fine.  It just means we throw out nodes whose
estimate is < tau/2 instead of those whose estimate is < tau

There's now a neat trick for doing this.  Let's do case of alpha = 00000
a string of k zeros.  So, we want the sum of squares over all
parities that don't include any of first k variables.  Remember, f is
a {-1, +1}-valued function.

The claim is that this sum just happens to equal the expected value,
over x in {0,1}^{n-k}, y in {0,1}^k, z in {0,1}^k, of fyx*fzx.

I.e. pick random suffix x.  Pick two random prefixes y and z and
multiply fyx by fzx.  Repeat many times and take the
average. Intuition: independent y and z will cancel out correlations
we don't want.  E.g., what if f was a parity function?  If f agrees
with alpha, then fyx=fzx so E[fyxfzx] = 1.  BUT, if f DOESN'T
agree with alpha, then Pr[fyx=fzx] = 1/2, so E[fyxfzx] = 0.

Now, since any f can be written as a sum of parities, hopefully we can
reduce the case of general f to the case of f is a parity function...
It's actually almost this easy.

	E[fyxfzx]
	 = E[ sum_v hat{f}_v phi_vyx sum_w hat{f}_w phi_wzx]

So just have to calculate: for two vectors v,w what is

	E [ phi_vyx * phi_wzx ]  ?
      x,y,z

Claim:  This is 0 if v != w.  If v=w we already showed this is 0 if
	v is not all 0s on the first k bits, else it is 1.
Proof:  If v!=w then just imagine we pick that differening bit last.

So,	E[fyxfzx]
	 = E[ sum_v hat{f}_v phi_vyx sum_w hat{f}_w phi_wzx]
	 = sum of squares of coeffs starting with k zeroes.

So, we're done for the case of alpha = all zeros.  What about other
alpha i.e., requiring parity to have a certain fixed dependence on
the first k bits?  Since we know the dependence alpha we can just
undo it.  Specifically, we instead ask for:

	E[fyxfzxphi_{alpha}yphi_{alpha}z]

where phi_alpha is the parity of the variables set to 1 in alpha.
then we get same as in above Claim, except the non-zero case is when
v=w and they are equal to alpha on the first k bits.

That's it.

Actually, one technical point: we need to estimate an expectation.
We'll do it by sampling.  OK since the quantity inside the expectation
is bounded in fact, it is always -1 or +1.
		15-859B Machine Learning Theory            03/19/14
More Fourier:
* Learning via Membership queries II
  - Connecting KM algorithm to L_1 length
  - Fourier spectrum of Decision Trees and DNF
* Classes of high SQ dimension have no large-margin kernels.
=======================================================================

Fourier analysis and Query learning
===================================
Looking at learning function f: {0,1}^n -> {-1,1}, where our goal is
to come up with an approximation g which agrees with f on most of the
domain i.e., want to do well with respect to the uniform distribution.

Considering basis of parity functions.  I.e.,hat{f}_v = <f,phi_v> =
E[fxphi_vx] is the correlation of f with the parity function
having indicator vector v, with respect to the uniform distribution.
Last time, we proved:

THM KM algorithm: if you have ability to make membership queries,
can find all large |hat{f}_v| > 1/polyn fourier coeffs in poly time.

Alg idea: estimate sum of squares of all fourier coefficients
corresponding to a given prefix.  Trick of using E[fyxfzx].  Grow
a tree, expand nodes with value > tau.

So, this means we can learn functions that have most of their length
in their large fourier coefficients.  Today: what kinds of functions
have this property.  Start with useful def and structural result:

Define L_1f = sum_v |hatf_v|.

So, this is the L_1 length of f in the parity basis.  Note that while
L_2 length is independent of your choice of basis and for boolean
functions it's always 1, the L_1 length depends on your basis!  E.g.,
if f is a parity function, then it has L_1 length = 1 in the parity
basis, but it has L_1 length = 2^{n/2} as do all boolean functions
in the standard basis where you list f as f0*2^{-n/2}, f1*2^{-n/2},....

THM: any boolean function f must have most of its L_2 length in
fourier coefficients that are larger than epsilon/L_1f:
   sum_{v: |hat{f}_v| < epsilon/L_1f} hat{f}_v^2 < epsilon

Proof: LHS < sum_{v: |hat{f}_v| < epsilon/L_1f} |hat{f}_v|*epsilon/L_1f
          <= epsilon/L_1f * sum_{v} |hat{f}_v|
           = epsilon.  QED

On the Fourier Spectrum of DNF and Decision Trees
=================================================
Consider a single conjunction not necessarily monotone.  Let Tx =
1 if x satisfies the conjunction and Tx=0 otherwise.  So, it's not a
boolean fn in our sense.  In fact <T,T> = E[TxTx] = 1/2^|T|.
If we analyze the fourier coefficients we get:

        hat{T}_v = E[Tx*phi_vx] = E[phi_vx | Tx=1]*Pr[Tx=1]

                  = 0 if phi_v has a relevant variable outside T by
		      usual parity argument
                  = 1/2^|T|*phi_vT otherwise, where phi_vT is the
		    value of phi_v on an example satisfying T.

         E.g., so it's very simple.  Sum of absolute values is 1.  Sum
         of squares is 1/2^|T| which we knew already

Analyzing Decision Trees
========================
Suppose f is a decision tree.  Using the terms corresponding to
positive leaves, we can write f as

	 fx = [T_1x + ... + T_mx]*2 - 1

So, to get the fourier coefficients hatf_v, we just add up for the
corresponding functions.  One easy thing to notice is that each
function here has a sum of absolute values of coefficients equal to 1
even the function -1 which has coefficient 1 along the empty parity
function and 0 everywhere else.  So, really crudely, this immediately
means that
	   sum_v |hatf_v| <= 2m+1
where m is the number of positive leaves.  So, this means we can use
the KM algorithm to learn Decision Trees with queries wrt the uniform
distribution.

Analyzing DNF
=============
For DNF we can't say that most of the DNF is in the large fourier
coefficients.  The problem with the above reasoning is that the terms
aren't disjoint so we can't just add them up.  But we *can* say that a
DNF formula must have at least one reasonably-sized fourier coefficient.

Claim: any m-term DNF f has a fourier coefficient of magnitide at least 1/4m.

Proof: We can assume f has a term T of size at most lg4m, else the
the probability that a random example is positive for f is at most
1/4, and so the empty all negative parity function has good correlation.

Now, here's the point: f has a noticeable correlation with T, because
when T=1, f=1 too, and when T=0 it doesn't matter.  Formally, <f,T> =
E[fxTx] = E[TxTx] = 1/2^|T| >= 1/4m.
Now, we use what we know about T to argue f has reasonable fourier
coefficients too.  Formally,

   <f,T> = sum_v hatf_v * hatT_v.

Now, using what we know about hatT_v, we get:

   <f,T> = sum_{v with rel vars inside T} hatf_v * 1/2^|T|phi_vT

and we know this equals 1/2^|T|.  So, we get:

    sum_{v with rel vars inside T} hatf_v * phi_vT = 1.

so at least one of them has magnitude at least 1/4m.
plus this says somethign about what their Fourier coefficients look like

======================================================

Strong-learning DNF wrt uniform distribution: the above result gives
us weak-learning.  Jackson CMU PhD thesis '94 showed how to use a
specific boosting algorithm which doesn't change the distirb too much,
to use this to get strong learning.  Key idea: in Fourier view, can
think of keeping distrib fixed, but having target change and become
non-boolean.   If doesn't change too much, can still argue about
having a large fourier coeff.

======================================================

High SQ dimension => no large-margin kernel
===========================================
Two lectures ago we proved that any class C with N > polyn pairwise
uncorrelated functions wrt D cannot be weak-learned over D in the SQ
model.  Will start today with a related result in some sense an
implication: any such class cannot have a large-margin kernel.

In particular, if C has N pairwise uncorrelated functions wrt D, then
for any kernel K, there must be some f in C with margin < 8/sqrtN.
Moreover, this holds even if we allow average hinge-loss as large as 1/2.

Proof:
  - Say the N uncorrelated functions are f_1, ..., f_N
  - We know for any hypothesis h, sum_i E_D[hxf_ix]^2 <= 1.
  - So, their average is at most 1/N, so
    avg_i |E_D[hxf_ix}| <= 1/sqrtN.

  - Now, suppose we had a good kernel for all f_i say margin > gamma
    on all points.
  - Fix one such f_i. We showed earlier that for a *random* linear
    separator h, E_h[|E_D[hxf_ix]|] = Omegagamma.
  - In fact, even if allow average hinge-loss as large as 1/2, you get
                E_h[|E_D[hxf_ix]|] >= gamma/8.

  - This implies there must *exist* h such that
                E_i[|E_D[hxf_ix]|] >= gamma/8.

		15-859B Machine Learning Theory            03/31/14
* Maximum entropy and maximum likelihood exponential model
* Connection to Winnow.

===========================================================================
- 2 different, natural, optimization criteria that have the same solution.
- turns out to do well in practice too: one of best algorithms for
  text classification problems.
- Winnow balanced/multiclass version can be viewed as a fast
  approximation.  Also related to SVMs

We'll be assuming that examples are given by n boolean features.
Also convenient to have dummy feature x_0 = 1 in every example.

High level
----------
First of all, we are going to be producing a hypothesis that, given x,
outputs a probability distribution over labels.  E.g., labels might be
{+,-} or might have a larger set of labels.  p_hy|x = the amount of
probability mass that hx assigns to label y.  Let S = data sample.
p_Sy|x = 1 if label of x is y, and 0 otherwise.  [or if x is in the
sample multiple times with different labels, then p_Sy|x is the
empirical distribution of these labels]

Second, we're not going to make assumptions about there being a
correct target function of some form --- we're just going to ask for
the hypothesis that minimizes a certain objective function.  Going to
be a convex optimization problem.

Here are 2 natural criteria that turn out to be equivalent.

1. Maximum entropy
==================
General principle for fitting a maximally ignorant prob dist given
known constraints. E.g., you roll a die many times and find that the
average value is 4 instead of 3.5.  Could ask for the maximum entropy
distribution subject to this constraint.  Entropy of a distribution p
over y is defined as:
          Hp = sum_y py*lg1/py
It's a measure of how spread out p is.  For instance, if we played 20
questions and I picked y from distribution p, and suppose we ignored
integrality issues so you could split the distribution 50/50 with
each question.  Then it would take you lg1/py questions to guess a
given y, and Hp would be the expected number of question asked.  [To
deal with integrality, imagine we change the game so that I pick k y's
iid from p and you need to identify the entire string.]

In the context of a probabilistic function over a dataset, the
standard measure used is the average entropy over the data. I.e.,

   Hp_h = average_{x in S} sum_y p_hy|x lg[1/p_hy|x]

The maximum entropy p_h is the one that predicts y uniformly at
random, no matter what x is.  But, let's say we want h to agree in
certain ways with the sample.  E.g., if the sample is 30% positive,
then we want h over x in S to be 30% positive on average.  If the
sample is 45% positive given that x_i = 1, then we want h to agree
with that too.  Specifically, we want:

1.  for all y, sum_{x in S} p_hy|x = sum_{x in S} p_Sy|x

2.  for all y, for all x_i,

      sum_{x in S:x_i=1} p_hy|x = sum_{x in S:x_i=1} p_Sy|x.

Note: it's easy to achieve these by just memorizing data: let p_h = p_S.
Note: can merge 1 into 2 because of dummy feature.

DEF: Let P be the set of probability distributions satisfying these
constraints.  Our objective: find the MAXIMUM ENTROPY h in P.

 [Note 1: usually in this area, a feature is property of the example
 and the label.  E.g., x_i = 1 and the  label is +.  But I will use
 feature in the standard machine-learning sense.  It doesn't matter much.]

 [Note 2: this is a pretty strange objective.  In particular, it says
 nothing about what h should do on points x not in S!  Luckily, there
 will exist reasonable functions that optimize this objective.]

2. MAXIMUM LIKELIHOOD EXPONENTIAL MODEL or LOGISTIC LINEAR SEPARATOR
========================================================================

Here's a natural family let's call it Q of probabilistic
hypotheses.  Let w_{iy} be a weight for feature i and label y.  Let
w_y be the vector for y.  Let p_hy|x be proportional to e^{w_y.x}.
I.e., p_hy|x = e^{w_y.x}/Zx, where Zx = sum_y' e^{w_y'.x}.

Of all these, pick the maximum likelihood hypothesis.  I.e., we want
the h in Q that maximizes the probability of the actual labels on the
data.

If you just think of positive and negative examples, and let w =
w_{+}-w_{-}, you get p_h+|x = e^{w.x}/1+e^{w.x}.  So you can think of
this as a linear separator w.x=0 with a prediction that is more confident as
x gets farther from the separator.  Which one maximizes likelihood?
We want to maximize the product of the probabilities of the observed
labels.  Equivalently, by taking -ln, we want to minimize a sum of
quantities we can view as penalties, where points near the separator
get a small penalty, and points on the wrong side of the separator get
a penalty that is roughly proportional to their distance to the plane [do it
out: p_h+|x = e^{w.x}/1+e^{w.x}, so -lnp_h+|x = -w.x + ln1+e^{w.x}
and draw picture]

Also, finding the max likelihood p_h in Q is a convex optimization problem,
because each example x gives a convex objective for w since it's convex
in w.x and then summing the convex objectives over all x gives
an overall convex objetive for w.  So this is something we can optimize
in polynomial time.

[Note: if we instead had a predictor p_h+|x=0.9 if x is on one side
of the separator and p_h+|x=0.1 if x is on the other side, then
maximizing likelihood would be the same as finding the separator
minimizing mistakes which among other things is NP-hard]

Interesting theorem: criteria 1 and 2 are duals.  p* in the
intersection of P and Q is the optimum solution to both.

ANALYSIS of MAXENT and MAXIMUM-LIKELIHOOD
==========================================

First, for a general distribution p_h, what is the likelihood?
product_{x in S} p_hlabelx|x.  Let's take the -log and divide by
|S|.  I.e., we want to find h in Q to:

    minimize average_{x in S} log1/p_hlabelx|x.

Can write it like this:

    minimize average_{x in S} sum_y p_Sy|x log[1/p_hy|x].


This has an interesting interpretation.  For two distributions p,q,
let's define the cross entropy:

     Hp,q = sum_y pylog[1/qy].

This is the average number of bits to encode y distributed according
to p, if we use the optimal code for q.  Hp,p = Hp.
Clearly, Hp,q >= Hp,p.

Let's extend this definition to average over {x in S} if p,q are
functions over x.  Hp,q = average_{x in S} sum_y py|xlog[1/qy|x]

So, HERE IS THE KEY POINT:
 - for criteria 2 we want h in Q that minimizes Hp_S,p_h.

 - for criteria 1 we want h in P that maximizes Hp_h,p_h.


The rest of the analysis will follow from the following lemma:

LEMMA: let p, p' in P, q in Q.  Then Hp,q = Hp',q.

[I.e., if we optimize our code for q, then all distribs in P are
equally good for us.  We can call this quantity HP,q, since it's the
same for all distributions in P].

PROOF: Hp,q =

  average_{x in S} sum_y py|x*[logZx - lge*w_y.x]

Notice that Z doesn't depend on y, and sum_y py|x = 1.  So, the Z
part just gives average_{x in S}[logZx] which doesn't depend on
p.  For the rest of it, let's factor out the lge and what's left is:

    - average_{x in S} sum_y py|x*[sum_i w_{yi}*x_i]

  = - sum_y sum_i w_{yi}*[average_{x in S} py|x x_i]

Notice that for a given i,y, the inside part is non-zero only for x in
S such that x_i=1.  It really only depends on the average over {x in
S: x_i=1} of py|x.  By definition of P, this is the same for all p
in P: we can replace p with p_S.  So, it didn't matter which p in P we
were looking at.  QED.


OK, now let's use this to prove that if p* is in both P and Q then it's
the optimum solution to both criteria.

Maximizing likelihood over Q:
 I.e., we want to show that Hp_S, p* <= Hp_S, q for any q in Q.

 But notice that p_S is in P.  So, the LHS equals Hp*,p* and the RHS
 equals Hp*,q, so by defn of H, LHS <= RHS.


Maximizing entropy over P:
 I.e., we want to show that Hp*,p* >= Hp,p for any p in P.

 Since p* is in Q, the LHS equals Hp,p*.  So again we have what we
 want by defn of H.

This proves the result.  One thing left is to argue that such a p*
exists: i.e., it is possible to satisfy the sample constraints of P
using a model of the expenential form Q.  Actually, we're in a little
trouble here: what if S has 100% positive examples, or all examples
with x_5=1 are negative?  The problem is there is no maximum value to
optimization 2.  We can handle this by either a replacing Q
with its closure bar{Q}, or else b redefining p_S to imagine the
dataset had at least one positive and one negative example with all
1's in it this is probably the better thing to do in practice.
Won't prove this part of the result but this is where the x_0 comes in.

Also, want uniqueness: if h in bar{Q} minimizes Hp_S,p_h and p* is
in P intersect bar{Q}, we want to argue that p_h = p*.  Can do this
using our main lemma.  Hp_S,p_h = Hp*,p_h, but this minimum occurs
only at p_h = p*.

RELATION TO BALANCED/MULTICLASS-WINNOW
======================================
It turns out the balanced winnow algorithm approximates the maxent
constraints if you set the multiplier to 1+epsilon, 1/1+epsilon.  In
particular, the number of pos->neg mistakes is approximately the
number of neg->pos mistakes and this holds even if you focus on just
the examples with x_i=1 which means the number of times it predicts
positive is approximately the number of positives in the sequence and
this holds even if you focus on just the examples with x_i=1.  Also,
it uses rules of the same form as Q except it just outputs the
highest probability label rather than a probability distribution.  In
practice it seems to work like a somewhat less smooth version of
maxent but can be a lot faster.

		15-859B Machine Learning Theory            04/02/14
Generalizations of combining expert advice results
* Online LP and the Kalai-Vempala algorithm
=========================================================================
Recap from earlier
==================
Combining expert advice: Have N prediction rules and want to perform
nearly as well as best of them.  Or, in game-theoretic setting, have
N strategies and want to do nearly as well of best of them in
repeated play.
  Randomized weighted majority algorithm:
    - Give each a weight starting at 1.
    - Choose rule at random with probability proportional to its weight.
    - When you are told the correct label, penalize rules that
      made a mistake by multiplying weight by 1-epsilon.  If costs in
      [0,1] then multiply by 1-epsilon^cost or 1-epsilon*cost
      both work.

  Get: E[Alg cost] <= 1+epsilon*OPT + 1/epsilon*logN.


Today: Notice that RWM bounds are good even if N is exponential in
the natual parameters of the problem.  But the running time in that
case is bad because we have to explicitly maintain a probability
distribution over experts.  Are there interesting settings where we
can get these kinds of bounds *efficiently*?

Today we will discuss an algorithm that can do this in many such cases.

[Do motivating example first]

Kalai-Vempala Algorithm
========================
The Kalai-Vempala algorithm applies to the following setting.

- We have a set S of feasible points in R^m.  Each time step t, we
  probabilistically pick x_t in S.  We are then given a cost vector
  c_t and we pay the dot-product c_t . x_t.

- The set S may have exponentially-many points, so we don't have time
  even to list its elements.  However, we have a magic offline
  algorithm M that, given any cost vector c, finds the x in S that
  minimizes c.x.  Want to use to produce an *online* algorithm so that
  our overall expected cost is not too much worse than for best x in S
  in hindsight.  Specifically, we want for any sequence c_1,...,c_T
  to get:
    E[Alg's cost] <= min_{x in S} c_1 + ... + c_T.x + [regret term]

- To have any hope, we will need to assume that S is bounded and so
  are the cost vectors c_t.

What are some things we can model this way?
===========================================

- Consider the following adaptive route-choosing problem.  Imagine
  each day you have to drive between two points s and t.  You have a
  map a graph G but you don't know what traffic will be like what
  the cost of each edge will be that day.  Say the costs are only
  revealed to you after you get to t on the evening news.  We can
  model this by having one dimension per edge, and each path is represented
  by the indicator vector listing the edges in the path.  Then the
  cost vector c is just the vector with the costs of each edge that
  day.  Notice that you *could* represent this as an experts problem
  also, with one expert per path, but the number of s-t paths can
  easily be exponential in the number of edges in the graph e.g.,
  think of the case of a grid.  However, given any set of edge
  lengths, we can efficiently compute the best path for that cost
  vector, since that is just a shortest-path problem.  You don't have
  to explicitly list all possible paths.

- Imagine a search engine that given a query q outputs a list of web
  pages.  User clicks on one, and we define cost as the depth in the
  list of the web-page clicked.  The next time q is queried you give a
  different ordering.  Want to do nearly as well as best fixed ordering
  in hindsight.  We could model this by having S be the set of permutation
  vectors describing the depth of each element, and c_t will be a
  coordinate vector indicating the item the user wanted.

- We can also model the standard experts problem this way by having
  each expert be its own coordinate, and c_t is the vector of costs at
  time t.  But bounds as a fn of n might be worse.

- More generally, this is like online linear programming.


The KV Algorithm
================
One natural thing to try is just run M to pick the best x in
hindsight, argmin_{x in S} c_1 + ... + c_{t-1}.x, and use that on
day t.  But this doesn't work.  E.g., imagine there are two routes to
work, one fast and one slow, but they alternate which is fast and
which is slow from day to day.  This procedure will always choose the
wrong one.  Instead, we will hallucinate a day 0 in which we have
random costs, from an appropriate distribution.  Then we will run M to
pick the x that minimizes c_0 + c_1 + ... + c_{t-1}.x.

To analyze this, we will argue in stages.

Step 1: First, we will show that picking
	argmin_{x in S} c_1 + ... + c_t.x
*does* work.  I.e., if you find the best in hindsight tomorrow and use
that today.  This is maybe not surprising but also not obvious.  Note
this is *not* the same as the x that minimizes c_t . x, which
obviously would be super-optimal.

Now, let algorithm A be the one that minimizes c_1 + ... + c_{t-1}.x.
Let B be the one that minimizes c_1 + ... + c_t.x.
They both go to the bar and start drinking.  As they drink, their
objective functions get fuzzier and fuzzier.  We end up getting:
  - A' that minimizes  c_0A + c_1 + ... + c_{t-1}.x.
  - B' that minimizes  c_0B + c_1 + ... + c_t.x.
where c_0A, c_0B are picked at random in [-1/epsilon,1/epsilon]^m.
Could be random in [0,2/epsilon]^m if we don't want negatives, e.g.,
in shortest path, but conceptually earier to think of centered box
Could also use a ball instead of a cube and get somewhat different
bounds.  Cube is simpler anyway.  As epsilon gets smaller, A and B
start behaving more and more alike.

Step 2 is to show that for an appropriate value of epsilon, B' is not
too much worse than B, and A' is close to B'.  This implies A' is good.

Preliminaries
=============
- We will assume that the maximum L_1 length sum of
  absolute values of any cost vector is 1. If D is the L_1 diameter
  of S, the bound we will show is:
     E[Alg's cost] < OPT + Depsilon*T/2 + 1/epsilon
  So, setting epsilon = sqrt2/T, we get:
     E[Alg's cost] < OPT + D*sqrt2T
  If you convert to the experts setting, where c in [0,1]^m, the
  result you will get is an m inside the square root.  This is not
  as good as the standard experts bounds.   They give a different
  distribution for hallucinating c_0 that fixes that problem.

Step 1
======
Define x_t = argmin_{x in S} c_1 + ... + c_t . x.
We need to show that:
     c_1 . x_1 + ... + c_T . x_T  <= c_1 + ... + c_T . x_T
In other words, we do at least as well using algorithm B as the
optimal fixed x in hindsight does.  We can do this by induction:

- By induction, we can assume:
     c_1.x_1 + ... + c_{T-1}.x_{T-1} <= c_1+...+c_{T-1}.x_{T-1}.
  And we know, by definition of x_{T-1}, that:
     c_1 + ... + c_{T-1} . x_{T-1} <= c_1 + ... + c_{T-1} . x_T
  So, putting these together, and adding c_T . x_T to both sides, we
  get what we want.

Step 2:
=======
Let's start with the easier part, showing that A' and B' are close.

- A' is picking a random objective function from a box of
  side-length 2/epsilon centered at c_1 + ... + c_{t-1}.  B' is
  picking a random objective function from a box of side-length
  2/epsilon centered at c_1 + ... c_t.  Let's call the boxes boxA
  and boxB.

- These boxes each have volume V = 2/epsilon^m.  Since their centers
  differ by a vector c_t of L_1 length at most 1, the intersection I of
  the boxes has volume at least 2/epsilon^m - |c_t|2/epsilon^{m-1}
  >= V1 - epsilon/2.  [[this is where the L_1 length of the cost
  vectors comes in]]

- This means that A' can't be much worse than B'.  In particular, say
  alpha is your expected loss if you were to pick x by feeding a
  random point c in I to our offline oracle M.  We can view B' as with
  probability 1-epsilon/2 doing exactly this and getting expected loss
  alpha, and with probability epsilon/2 choosing a random c in boxB-I,
  and at best getting a loss of 0.  We can view A' as with probability
  1-epsilon/2 getting an expected loss of alpha, and with probability
  epsilon/2 getting at worst a loss of D. [Actually, we never said the losses
  had to be non-negative.  The point is that the diameter of S is at most
  D, so the biggest possible gap between the losses of 2 points in S
  on any given c is D. Actually, for this part of the argument, we
  only need L_infty length of c is at most 1, not L_1 length]. The
  difference between the two is D*epsilon/2.  This happens for T time
  steps, so that counts for the DT*epsilon/2 part.

Now, to finish, we need to argue about B versus B'.  This will give us
the D/epsilon part.  This turns out to be pretty easy:

- View the random offset as an initial day 0.  By the argument from
  Step 1, we know that:
       c_0 . x_0 + ... + c_T . x_T <= c_0 + ... + c_T . x_T.
  where we define x_t as argmin[x . c_0 + ... + c_T]

- But the left-hand-side = costB' + c_0 . x_0 B' didn't actually
  have to pay for day 0.  The RHS is at most OPT + c_0 . x_opt where
  x_opt is what opt picks if you don't count the fake day 0.  Putting
  this together, we get:
      costB' <= OPT + c_0x_opt - x_0.
  Now, since each entry in c_0 has magnitude at most 1/epsilon, the
  RHS is at most OPT + D/epsilon due to the diameter of the space.

Done!
")
