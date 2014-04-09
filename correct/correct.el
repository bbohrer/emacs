
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


(defun pairs (L) "All pairs of consecutive elements in L"
  (if (null L)
      nil
    (if (null (cdr L))
        nil
      (cons (cons (car L) (cadr L)) (pairs (cdr L))))))

(defun markov-rules (corpus rule-count)
  "Given a CORPUS string, generates a set of RULE-COUNT prediction rules based on the
   previous word. Returns rules as a list of triples (prev, next, p) that say 'If the
   previous word was PREV, predict NEXT with confidence P'."
  (let* ((words (split-string corpus))
         (pair-list (pairs words))
         (counts (do-count pair-list (make-hash-table :test 'equal)))
         (freqs (freq-of-count counts)))
    (take (sort-by-freq freqs) rule-count)))
