(load "~/private/emacs/correct/wiki")
(load "~/private/emacs/correct/bnc1k")
;(load "~/Documents/emacs/correct/wiki")
;(load "~/Documents/emacs/correct/bnc1k")
(require 'cl)
(setq max-specpdl-size 100000)
(defun cadar (x) (car (cdr (car x))))

; Keyboard layouts - each layout is a list of rows, each of which is a list of pairs of characters on the same key.
;
; Layout for (programmer) Dvorak
(setq dvorak-keys  '(
((?\$ ?\~) (?\& ?\%)  (?\[ ?7)  (?\{ ?5) (?\} ?3) (?\( ?1) (?\= ?9) (?\* ?0) (?\) ?2) (?\+ ?4) (?\] ?6) (?\! ?8)  (?\# ?\`))
((?\; ?\:) (?\, ?\<) (?\. ?\>) (?p ?P)  (?y ?Y)  (?f ?F)  (?g ?G)  (?c ?C)  (?r ?R)  (?l ?L)  (?\/ ?\?) (?\@ ?^)  (?\\ ?\|))
((?a ?A)   (?o ?O)   (?e ?E)   (?u ?U)  (?i ?I)  (?d ?D)  (?h ?H)  (?t ?T)  (?n ?N)  (?s ?S)  (?\- ?\_))
((?\' ?\") (?q ?Q)   (?j ?J)   (?k ?K)  (?x ?X)  (?b ?B)  (?m ?M)  (?w ?W)  (?v ?V)  (?z ?Z))
))

(setq qwerty-keys  '(
((?\` ?\~) (?1 ?\!)  (?2 ?\@)  (?3 ?\#) (?4 ?\$) (?5 ?\%) (?6 ?^) (?7 ?\&) (?8 ?\*) (?9 ?\() (?0 ?\)) (?\- ?\_)  (?\= ?\+))
((?q ?Q) (?w ?W) (?e ?E) (?r ?R)  (?t ?T)  (?y ?Y)  (?u ?U)  (?i ?I)  (?o ?O)  (?p ?P)  (?\[ ?\{) (?\] ?\})  (?\\ ?\|))
((?a ?A)   (?s ?S)   (?d ?D)   (?f ?F)  (?g ?G)  (?h ?H)  (?j ?J)  (?k ?K)  (?l ?L)  (?\; ?\:)  (?\' ?\"))
((?z ?Z) (?x ?X)   (?c ?C)   (?v ?V)  (?b ?B)  (?n ?N)  (?m ?M)  (?\, ?\<)  (?\. ?\>)  (?\/ ?\?))
))

(setq all-keys
 '(?\$ ?\& ?\[ ?\{ ?\} ?\( ?\= ?\* ?\) ?\+ ?\] ?\! ?\# ?\; ?\, ?\. ?\/ ?\@ ?\\
   ?\' ?\~ ?\% ?\` ?\? ?^ ?\| ?\: ?\< ?\> ?\" ?7 ?5 ?3 ?1 ?9 ?0 ?2 ?4 ?6 ?8 ?p
   ?y ?g ?f ?c ?r ?l ?a ?o ?e ?u ?i ?d ?h ?t ?n ?s ?q ?j ?k ?x ?b ?m ?w ?v
   ?z ?P ?Y ?F ?G ?C ?R ?L ?O ?A ?E ?U ?I ?D ?H ?T
   ?N ?S ?Q ?J ?K ?X ?B ?M ?W ?V ?Z))

;; Greatest manhattan distance between any two keys
(setq max-dist 15)

(defun char-pos (table char)
  (let ((x 0) (y 0) (done nil))
    (while (not (or done (null table)))
      (let ((row (car table)))
        (while (not (or done (null row)))
          (if (or (= char (caar row))
                  (= char (cadar row)))
              (setq done t)
            (setq x (+ x 1)))
          (setq row (cdr row))))
      (if (not done)
          (progn
            (setq x 0)
            (setq y (+ y 1))))
      (setq table (cdr table)))
    (if done
        (cons x y)
      nil)))

(defun key-dist (table key1 key2)
  (let* ((pos1 (char-pos table key1))
         (pos2 (char-pos table key2)))
    (if (null pos2) (/ key2 0))
    (/ (float (+ (abs (- (car pos1) (car pos2)))
                 (abs (- (cdr pos1) (cdr pos2)))))
       (float max-dist))))

(defun dist-map (table)
  (let ((keys1 all-keys)
        (key-map (make-char-table 'key-map)))
    (while (not (null keys1))
      (let ((keys2 all-keys)
            (inner-table (make-char-table 'key-map)))
        (while (not (null keys2))
          (aset inner-table (car keys2) (key-dist table (car keys1) (car keys2)))
          (setq keys2 (cdr keys2)))
        (aset key-map (car keys1) inner-table)
        (setq keys1 (cdr keys1))
        (setq keys2 all-keys)))
    key-map))

(defun subst-map (char)
  (let ((chars all-keys)
        (table (make-char-table 'subst-map)))
    (while (not (null chars))
      (aset table (car chars) (if (= (car chars) char) 0 1))
      (setq chars (cdr chars)))
    table))

(defun memo-table (n m)
  (let ((memo (make-vector n nil)))
    (dotimes (i n)
      (aset memo i (make-vector m nil)))
    memo))

(defun drop-cost (subst c)
  (if (aref subst c)
      (aref subst c)
    (/ c 0)))
(defun dist-cost (dist d1 d2)
  (aref (aref dist d1) d2))

(defun levenshtein (dist subst s1 s2)
  (let ((memo (memo-table (length s1) (length s2))))
    (flet ((lev (i j)
                (if (= (min i j) -1)
                    ;; Need to account for cost of dropping characters, don't care yet
                    (+ 1 (max i j))
                  (let ((stored (aref (aref memo i) j)))
                    (if stored
                        stored
                      (let* ((c1 (aref s1 i))
                             (c2 (aref s2 j))
                             (res (min (+ (drop-cost subst c1) (lev (- i 1) j))
                                       (+ 1 (lev i (- j 1)))
                                       (+ 1 (lev (- i 1) (- j 1))
                                          (dist-cost dist c1 c2)))))
                        (aset (aref memo i) j res)
                        res))))))
      (lev (- (length s1) 1) (- (length s2) 1)))))


(defun build-lev-dict (words)
  "Given a list of strings, builds an initial dictionary (word) -> (label, distance)
   mapping input words to their corrected word and the distance to it"
  (let ((lev-dict (make-hash-table :test 'equal)))
    (while (not (null words))
      (puthash (car words) (cons (car words) 0) lev-dict)
      (setq words (cdr words)))
    lev-dict))
(defun safe-sort (L f) (sort (copy-sequence L) f))

(defun init-lev (keys char words)
  (let ((mywords (safe-sort words (function string<))))
    (cons
     (cons (dist-map keys) (subst-map char))
     (cons (build-lev-dict mywords) mywords))))

(defun predict-lev (state candidate)
  "Given a candidate value, predicts a correction
   based on some state, returning (prediction, dist)"
  (let* ((dist (caar state))
         (subst (cdar state))
         (dict (cadr state))
         (words (cddr state))
         (best-word candidate)
         (best-dist 9999999)
         (cached-answer (gethash candidate dict)))
    (if cached-answer
        cached-answer
      (while (not (null words))
        (let* ((word (car words))
               (dist (levenshtein dist subst candidate word)))
          (if (< dist best-dist)
              (progn
                (setq best-dist dist)
                (setq best-word word))))
        (setq words (cdr words)))
      (cons best-word best-dist))))

(defun predict-combo (p candidate)
  (let* ((state (car p))
         (chain (cdr p))
         (dist (caar state))
         (subst (cdar state))
         (dict (cadr state))
         (words (cddr state))
         (best-word candidate)
         (best-dist 9999999)
         (cached-answer (gethash candidate dict)))
    (if cached-answer
        cached-answer
      (while (not (null words))
        (let* ((word (car words))
               (lev-dist (levenshtein dist subst candidate word))
               (p (chain-prob chain candidate))
               (adj-dist (* (- 1.0 p) lev-dist)))
          (if (< adj-dist best-dist)
              (progn
                (setq best-dist adj-dist)
                (setq best-word word))))
          (setq words (cdr words)))
      (cons best-word best-dist))))

(defun chain-prob (chain input)
  (let* ((prev (car chain))
         (table (cdr chain))
         (next (if (null prev) 0.0
                 (if (null (gethash prev table))
                     0.0
                   (gethash input (gethash prev table))))))
    (setcar chain input)
    next))

(defun add-to-words (word words)
  (cond ((null words) (cons word nil))
        ((string< word (car words)) (cons word words))
        (let ((iter words))
          (while (not (null (cdr iter)))
            (cond ((string= (cadr iter) word)
                   (setq iter nil))
                  ((string< (cadr iter) word)
                   (progn (setcdr iter (cons word (cdr iter)))
                          (setq iter nil)))
                   (setq iter (cdr iter))))
          words)))

(defun update-state (state label pred-word)
  (let ((dict (cadr state))
        (words (cddr state)))
    (if (string= label pred-word)
        state
      (puthash example (cons pred-word (levenshtein (caar state) (cdar state) label pred-word)) dict)
      (cons (car state)
            (cons dict
                  (add-to-words label words))))))

(defun learn-word (state example label)
  "Predicts the correction for example, then learns it if the guess was wrong"
  (let* ((prediction (predict-lev state example))
         (pred-word (car prediction))
         (pred-dist (cdr prediction)))
    (cons pred-word (update-state state label pred-word))))

(defun pairs-t (L acc) "All pairs of consecutive elements in L"
  (if (null L)
      acc
    (if (null (cdr L))
        acc
      (pairs-t (cdr L) (cons (cons (car L) (cadr L)) acc)))))

(defun pairs (L)
  (let ((result nil))
    (while (not (null L))
      (setq result (cons (cons (car L) (cadr L)) result))
      (setq L (cdr L)))
    result))

(defun add-count (hash prev next)
  (if (null (gethash prev hash))
      (puthash prev (cons 0 (make-hash-table :test 'equal)) hash))
  (let* ((count-prevhash (gethash prev hash))
         (count (car count-prevhash))
         (prevhash (cdr count-prevhash))
         (val (gethash next prevhash)))
    (puthash next (+ 1 (if (null val) 0 val)) prevhash)
    (puthash prev (cons (+ 1 count) prevhash) hash))
  hash)

(defun do-count (pairs counts)
  (while (not (null pairs))
    (setq counts (add-count counts (caar pairs) (cdar pairs)))
    (setq pairs (cdr pairs)))
  counts)

(defun freq-of-count (hash)
  (maphash
   (lambda (prev count-prevhash)
     (maphash (lambda (next next-count)
                (puthash next (/ (float next-count) (float (car count-prevhash))) (cdr count-prevhash)))
              (cdr count-prevhash))
     (puthash prev (cdr count-prevhash) hash))
   hash)
  hash)

(defun best-of-hash (hash)
  (maphash
   (lambda (prev count-prevhash)
     (let ((best-word nil)
           (best-count nil))
     (maphash (lambda (next next-count)
                (if (or (null best-count) (> next-count best-count))
                    (progn (setq best-count next-count)
                           (setq best-word next))))
              (cdr count-prevhash))
     (puthash prev best-word hash)))
   hash)
  hash)

(defun sort-by-freq (rules)
  (safe-sort rules (lambda (rule1 rule2) (> (car (cddr rule1)) (car (cddr rule2))))))

(defun build-markov (corpus)
  (let* ((words (split-string corpus))
         (pair-list (pairs words))
         (counts (do-count pair-list (make-hash-table :test 'equal))))
    (best-of-hash counts)))

(defun build-markov-full (corpus)
  (let* ((words (split-string corpus))
         (pair-list (pairs words))
         (counts (do-count pair-list (make-hash-table :test 'equal))))
    (freq-of-count counts)))

;; (defun markov-rules (corpus rule-count)
;;   "Given a CORPUS string, generates a set of RULE-COUNT prediction rules based on the
;;    previous word. Returns rules as a list of triples (prev, next, p) that say 'If the
;;    previous word was PREV, predict NEXT with confidence P'."
;;   (let* ((words (split-string corpus))
;;          (pair-list (pairs words))
;;          (counts (do-count pair-list (make-hash-table :test 'equal)))
;;          (freqs (freq-of-count counts)))
;;     (take (sort-by-freq freqs) rule-count)))

(defun take-t (L n acc)
  (if (< n 1) acc
    (if (null L) acc
      (take-t (cdr L) (- n 1) (cons (car L) acc)))))

(defun take (L n)
  (let ((acc nil))
    (while (not (or (null L) (<= n 0)))
      (setq acc (cons (car L) acc))
      (setq L (cdr L)))
    (reverse acc)))

(defun mk-pred-lev (state)
  (cons 'lev state))

(defun mk-pred-markov (state)
  (cons 'markov (cons nil state)))

(defun mk-pred-combo (state chain)
  (cons 'combo (cons state (cons nil chain))))

(defun predict-markov (p input)
  (let* ((prev (car p))
         (table (cdr p))
         (next (if (or (null prev) (null (gethash prev table)))
                   input (gethash prev table))))
    (setcar p input)
    next))

(defun predict (predictor input)
  (if (eq (car predictor) 'lev)
      (car (predict-lev (cdr predictor) input))
    (if (eq (car predictor) 'markov)
        (predict-markov (cdr predictor) input)
      (car (predict-combo (cdr predictor) input)))))

(defun mk-rwm (predictors)
  (mapcar (lambda (p) (cons 1.0 p)) predictors))

(defun total-weight (predictors)
  (let ((weight 0.0))
    (while (not (null predictors))
      (setq weight (+ weight (caar predictors)))
      (setq predictors (cdr predictors)))
    weight))

(defun avg-weight (predictors)
  (/ (total-weight predictors) (float (length predictors))))

(defun threshold-weight (predictors)
  (/ (avg-weight predictors) 4.0))

(defun rwm-majority (weights predictions)
  (let ((weight-table (make-hash-table :test 'eq))
        (best-pred nil)
        (best-weight nil))
    (while (not (null weights))
      (let* ((weight (car weights))
             (pred (car predictions))
             (old-weight (gethash pred weight-table)))
        (if old-weight
            (puthash pred (+ weight old-weight) weight-table)
          (puthash pred weight weight-table))
        (setq weights (cdr weights))
        (setq predictions (cdr predictions))))
    (maphash (lambda (k w) (if (or (null best-weight) (> w best-weight))
                             (setq best-pred k)
                             (setq best-weight weight))) weight-table)
    best-pred))

(defun update-predictor (pred theta)
  (if (< (car pred) theta) pred
    (cons (/ (car pred) 2.0) (cdr pred))))

(defun rwm-update (rwm predictions majority)
  (let* ((theta (threshold-weight rwm))
         (new nil))
    (while (not (null rwm))
      (if (string= (car predictions) majority)
          (setq new (cons (car rwm) new))
        (setq new (cons (update-predictor (car rwm) theta) new)))
      (setq rwm (cdr rwm))
      (setq predictions (cdr predictions)))
    new))

(defun rwm-learn-word (rwm example label)
  (let* ((predictions (mapcar (lambda (p) (predict (cdr p) example)) rwm))
         (weights (mapcar (function car) rwm))
         (majority (rwm-majority weights predictions)))
    (cons majority (rwm-update rwm predictions majority))))

(defun rwm-learn-words (rwm words labels)
  (let ((output nil))
    (while (not (null words))
      (let ((res (rwm-learn-word rwm (car words) (car labels))))
        (setq output (cons (car res) output))
        (setq rwm (cdr res))
        (setq words (cdr words))
        (setq labels (cdr labels))))
    (cons (nreverse output) rwm)))

(defun rwm-learn-string (rwm string labels)
  (rwm-learn-words rwm (split-string string) (split-string labels)))

(setq test-lev (init-lev dvorak-keys -1 dict))
(setq test-full (build-markov-full corpus))
(setq test-drop (init-lev dvorak-keys ?r dict))
(setq test-markov (build-markov corpus))
(setq test-rwm (mk-rwm (list (mk-pred-lev test-lev) (mk-pred-markov test-markov)
                             (mk-pred-combo test-lev test-full)
                             )))
(setq res-rwm (rwm-learn-string test-rwm "I thnk he would if he could" "I think he would if he could"))


