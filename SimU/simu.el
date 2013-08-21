(require 'widget)

(eval-when-compile
  (require 'wid-edit))

(defvar simu-uni-name)
(defvar simu-player-name)


(defun simu ()
  "Play SimU"
  (interactive)
  (switch-to-buffer "*SimU*")
  (kill-all-local-variables)
  (start-screen)
)

(defvar simu-start-player-name)
(defvar simu-start-univ-name)
(defvar simu-start-start-button)

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
  (setq simu-start-player-name (widget-create 'editable-field
           :size 13
           :format "What is your name?: %v " ; Text after the field!
           "Spartacus"))
  (widget-insert "\n\n")
  (setq simu-start-univ-name (widget-create 'editable-field
           :size 13
           :format "What is your school named?: %v " ; Text after the field!
           "Roman Institute of Technology"))
  (widget-insert "\n\n")
  (setq simu-start-start-button (widget-create 'push-button
                 :notify (lambda (&rest ignore)
                           (setq simu-univ-name (widget-value simu-start-univ-name))
                           (setq simu-player-name (widget-value simu-start-player-name))
                           (widget-delete simu-start-univ-name)
                           (widget-delete simu-start-player-name)
                           (widget-delete simu-start-start-button)
                           (main-screen))
                 "Let's Go!"))
    (widget-setup))

(defun spacer () (widget-insert "\n\n"))

 (defun main-screen ()
   "Primary game screen - allows selecting between other screens"
   (force-erase-buffer)
   (widget-insert (format "You are %s, supreme ruler of %s.
From here you can see all your dominion:\n\n" simu-player-name simu-univ-name))
   (setq simu-main-finance (widget-create 'push-button
                                          :notify (lambda (&rest ignore)
                                                    (cleanup-main)
                                                    (finance-screen))
                                          "Bursar's Office"))
   (spacer) 
   (setq simu-main-admissions (widget-create 'push-button
                                             :notify (lambda (&rest ignore)
                                                       (cleanup-main)
                                                       (admissions-screen))
                                             "Admissions Office"))
   (spacer)
   (setq simu-main-academics (widget-create 'push-button
                                            :notify (lambda (&rest ignore)
                                                      (cleanup-main)
                                                      (academics-screen))
                                            "Dean's Office"))
   (spacer)
   (setq simu-main-housing (widget-create 'push-button
                                          :notify (lambda (&rest ignore)
                                                    (cleanup-main)
                                                    (housing-screen))
                                          "Housing Office"))
   (spacer)
   (setq simu-main-dining (widget-create 'push-button
                                         :notify (lambda (&rest ignore)
                                                        (cleanup-main)
                                                        (dining-screen))
                                         "Dining Office"))
   (spacer)
   (setq simu-main-sports (widget-create 'push-button 
                                         :notify (lambda (&rest ignore)
                                                        (cleanup-main)  
                                                        (sports-screen))
                                         "Coach"))
   (spacer)
   (setq simu-main-career (widget-create 'push-button
                                         :notify (lambda (&rest ignore)
                                                        (cleanup-main)
                                                        (career-screen))
                                         "Career Center"))
   (widget-setup))
