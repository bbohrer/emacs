(load "~/private/emacs/correct/wiki")
(require 'cl)
(defun memo-table (n m)
  (let ((memo (make-vector n nil)))
    (dotimes (i n)
      (aset memo i (make-vector m nil)))
    memo))

(defun levenshtein (s1 s2)
  (let ((memo (memo-table (length s1) (length s2))))
    (flet ((lev (i j)
                (let ((stored (aref (aref memo i) j)))
                  (if stored
                      stored
                    (let ((res (if (= (min i j) 0)
                                   (max i j)
                                 (min (+ 1 (lev (- i 1) j))
                                      (+ 1 (lev i (- j 1)))
                                      (+ (lev (- i 1) (- j 1))
                                         (if (= (aref s1 i) (aref s2 j))
                                             0
                                           1))))))
                      (aset (aref memo i) j res)
                      res)))))
          (lev (- (length s1) 1) (- (length s2) 1)))))

(levenshtein "scattergory" "category")


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
  (sort rules (lambda (rule1 rule2) (> (car (cddr rule1)) (car (cddr rule2))))))

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

(setq kgrams (markov-rules "sup dawg yo mang" 1000))

(nth 800 kgrams)
