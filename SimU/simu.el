(require 'widget)

(eval-when-compile
  (require 'wid-edit))

(defvar uni-name)
(defvar player-name)
(defvar year)
(defvar prestige)
(defconst interest 5)
(defvar tuition-amt)
(defvar finaid-amt)
(defvar endowment)
(defvar enrollment)

(setq year 1900)
(setq prestige 0)
(setq tuition-amt 3)
(setq finaid-amt 1)
(setq endowment 100)
(setq enrollment 200)

(defun simu ()
  "Play SimU"
  (interactive)
  (switch-to-buffer "*SimU*")
  (kill-all-local-variables)
  (start-screen)
)

(defun setup-screen ()
  (widget-setup)
  (widget-beginning-of-line))

(defun print-stats ()
  (widget-insert (propertize (format "  Year: %d      Endowment: $%dK     Prestige: %d\n"
                                     year endowment prestige)
                             'font-lock-face 
                             '(:foreground "white" :background "black")))
  (widget-insert "\n"))

(defvar start-player-name)
(defvar start-univ-name)
(defvar start-start-button)

(defun force-erase-buffer ()
  (let ((inhibit-read-only t))
        (erase-buffer)))

(defun start-screen ()
  "Draw the start screen and respond to user input"
  (force-erase-buffer)
  (remove-overlays)
  (use-local-map widget-keymap)
  (widget-insert 
"***********       Welcome to SimU       ***********\n
The year is 1900. You, fine sir or madam Emacs user,
have been elected President / Prime Minister / Supreme
Benefactor of a cozy little no-name college. Your 
mission, should you chose to accept it, is to take this
college and transform it over the next century or so
into the institution of your chosing, whether it be
and elite little private school, an elite not-so-little
private school, or burgeoning state school. 

")
  (setq start-player-name (widget-create 'editable-field
           :size 13
           :format "What is your name?: %v " ; Text after the field!
           "Spartacus"))
  (widget-insert "\n\n")
  (setq start-univ-name (widget-create 'editable-field
           :size 13
           :format "What is your school named?: %v " ; Text after the field!
           "Roman Institute of Technology"))
  (widget-insert "\n\n")
  (setq start-start-button (widget-create 'push-button
                 :notify (lambda (&rest ignore)
                           (setq univ-name (widget-value start-univ-name))
                           (setq player-name (widget-value start-player-name))
                           (widget-delete start-univ-name)
                           (widget-delete start-player-name)
                           (widget-delete start-start-button)
                           (main-screen))
                 "Let's Go!"))
    (setup-screen))

(defun spacer () (widget-insert "\n\n"))

(defun cleanup-main ()
  "Clear all the widgets created by the main play screen"
  (widget-delete main-finance)
  (widget-delete main-admissions)
  (widget-delete main-academics)
  (widget-delete main-housing)
  (widget-delete main-dining)
  (widget-delete main-sports)
  (widget-delete main-career)
  (widget-delete main-advance))

(defun advance-year ()
  (setq endowment (+ endowment (finance-profit)))
  (setq year (1+ year)))

(defun main-screen ()
  "Primary game screen - allows selecting between other screens"
  (force-erase-buffer)
  (print-stats)
  (widget-insert 
"From here you can visit different offices to control
different aspects of the university:

")
  (setq main-finance (widget-create 'push-button
                                         :notify (lambda (&rest ignore)
                                                   (cleanup-main)
                                                   (finance-screen))
                                         "Bursar's Office"))
  (spacer) 
  (setq main-admissions (widget-create 'push-button
                                            :notify (lambda (&rest ignore)
                                                      (cleanup-main)
                                                      (admissions-screen))
                                            "Admissions Office"))
  (spacer)
  (setq main-academics (widget-create 'push-button
                                           :notify (lambda (&rest ignore)
                                                     (cleanup-main)
                                                     (academics-screen))
                                           "Dean's Office"))
  (spacer)
  (setq main-housing (widget-create 'push-button
                                         :notify (lambda (&rest ignore)
                                                   (cleanup-main)
                                                   (housing-screen))
                                         "Housing Office"))
  (spacer)
  (setq main-dining (widget-create 'push-button
                                        :notify (lambda (&rest ignore)
                                                  (cleanup-main)
                                                  (dining-screen))
                                        "Dining Office"))
  (spacer)
  (setq main-sports (widget-create 'push-button 
                                        :notify (lambda (&rest ignore)
                                                  (cleanup-main)  
                                                  (sports-screen))
                                        "Coach"))
  (spacer)
  (setq main-career (widget-create 'push-button
                                        :notify (lambda (&rest ignore)
                                                  (cleanup-main)
                                                  (career-screen))
                                        "Career Center"))
  (widget-insert
"

  When you're done, it's time to

")
  (setq main-advance (widget-create 'push-button
                                    :notify (lambda (&rest ignore)
                                              (cleanup-main)
                                              (advance-year)
                                              (main-screen))
                                    "Advance to Next Year"))
  (setup-screen))

(defun finance-interest-income ()
  (/ (* endowment interest) 100))

(defun finance-tuition-income ()
  (* enrollment (- tuition-amt finaid-amt)))

(defun finance-income ()
  "Income from all sources, after accounting for financial aid"
  (+ (finance-interest-income) (finance-tuition-income)))

(defun finance-profit ()
  "Income less expenses"
  (finance-income))


(defvar finance-tuition)
(defvar finance-finaid)

(defun finish-finance ()
  ;; TODO - handle errors
  (setq tuition-amt (string-to-number (widget-value finance-tuition)))
  (setq finaid-amt (string-to-number (widget-value finance-finaid)))
  (widget-delete finance-tuition)
  (widget-delete finance-finaid))

(defun finance-screen ()
  "The bursar's office where you can manage your endowment"
  (force-erase-buffer)
  (print-stats)
  (widget-insert (format "Endowment: %dK\n" endowment))
  (widget-insert (format "Interest rate: %d%%\n" interest))
  (widget-insert (format "Income from interest: %dK\n\n" (finance-interest-income)))
  (widget-insert (format "Enrollment: %d students\n" enrollment))
  (setq finance-tuition (widget-create 'editable-field
                                :size 3
                                :format "Tuition: $%vK"
                                (number-to-string tuition-amt)
                                ))
  (widget-insert "\n")
  (setq finance-finaid (widget-create 'editable-field
                              :size 3  
                              :format "Average financial aid: $%vK"
                              (number-to-string finaid-amt)))
  (widget-insert "\n")
  (widget-insert (format "Net income from tuition: $%dK\n" (finance-tuition-income)))
  (widget-insert (format "Total net income: $%dK\n\n" (finance-income)))

  (widget-create 'push-button
                 :notify (lambda (&rest ignore)
                           (finish-finance)
                           (finance-screen))
                 "Recalculate")
  (widget-insert " ")
  (widget-create 'push-button
                 :notify (lambda (&rest ignore)
                           (finish-finance)
                           (main-screen))
                 "Done!")
  (setup-screen))
