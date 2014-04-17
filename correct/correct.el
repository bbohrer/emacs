;;(load "~/private/emacs/correct/wiki")
;;(load "~/private/emacs/correct/bnc15k")
(load "~/Documents/emacs/correct/wiki")
(load "~/Documents/emacs/correct/bnc1k")

(require 'cl)
(defun memo-table (n m)
  (let ((memo (make-vector n nil)))
    (dotimes (i n)
      (aset memo i (make-vector m nil)))
    memo))

(defun levenshtein (s1 s2)
  (let ((memo (memo-table (length s1) (length s2))))
    (cl-flet ((lev (i j)
                (if (= (min i j) -1)
                    (+ 1 (max i j))
                  (let ((stored (aref (aref memo i) j)))
                    (if stored
                        stored
                      (let ((res (min (+ 1 (lev (- i 1) j))
                                      (+ 1 (lev i (- j 1)))
                                      (+ (lev (- i 1) (- j 1))
                                         (if (= (aref s1 i) (aref s2 j))
                                             0
                                           1)))))
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
(defun safe-sort (L f) (sort (copy-list L) f))

(defun init-lev (words)
  (let ((mywords (safe-sort words (function string<))))
    (cons (build-lev-dict mywords) mywords)))

(defun predict-lev (state candidate)
  "Given a candidate value, predicts a correction
   based on some state, returning (prediction, dist)"
  (let* ((dict (car state))
        (words (cdr state))
        (best-word candidate)
        (best-dist 9999999)
        (cached-answer (gethash candidate dict)))
    (if cached-answer
        cached-answer
      (while (not (null words))
        (let* ((word (car words))
               (dist (levenshtein candidate word)))
          (if (< dist best-dist)
              (progn
                (setq best-dist dist)
                (setq best-word word))))
      (setq words (cdr words)))
      (cons best-word best-dist))))

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
  (let ((dict (car state))
        (words (cdr state)))
    (if (string= label pred-word)
        state
      (puthash example (cons pred-word (levenshtein label pred-word)) dict)
      (cons dict
            (add-to-words label words)))))
(string< "a" "b")
(defun learn-word (state example label)
  "Predicts the correction for example, then learns it if the guess was wrong"
  (let* ((prediction (predict-lev state example))
         (pred-word (car prediction))
         (pred-dist (cdr prediction)))
    (cons pred-word (update-state state label pred-word))))

(setq test-lev (init-lev dict))
(setq result (predict-lev test-lev "thery"))
(setq test-lev (cdr (learn-word test-lev "monad" "monad")))
"hi veeryone my name is brandaon i am a guy and i like to learn machine learning thery about
machines leaning machine learning theory"



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
                (puthash next (cons next-count (/ (float next-count) (float (car count-prevhash)))) (cdr count-prevhash)))
              (cdr count-prevhash))
     (puthash prev (cdr count-prevhash) hash))
   hash)
  (let ((freq-list nil))
    (maphash
     (lambda (prev nexthash)
       (maphash
        (lambda (next freq)
          (setq freq-list (cons (cons prev (cons next freq)) freq-list)))
        nexthash))
     hash)
    freq-list))

(defun sort-by-freq (rules)
  (safe-sort rules (lambda (rule1 rule2) (> (car (cddr rule1)) (car (cddr rule2))))))

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


(defun markov-rules (corpus rule-count)
  "Given a CORPUS string, generates a set of RULE-COUNT prediction rules based on the
   previous word. Returns rules as a list of triples (prev, next, p) that say 'If the
   previous word was PREV, predict NEXT with confidence P'."
  (let* ((words (split-string corpus))
         (pair-list (pairs words))
         (counts (do-count pair-list (make-hash-table :test 'equal)))
         (freqs (freq-of-count counts)))
    (take (sort-by-freq freqs) rule-count)))
