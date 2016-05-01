(load "package://pr2eus/robot-interface.l")
(load "robotis_op2.l")
(load "irteus/demo/walk-motion.l")

(defclass robotis_op2-interface
  :super robot-interface
  :slots (lzmp rzmp lfsr rfsr))

(defmethod robotis_op2-interface
  (:init
   (&rest args &key (robot robotis_op2-robot))
   (send-super* :init :robot robot :joint-states-topic "robot_joint_states" args)
   (ros::advertise "controller_joint_states" sensor_msgs::JointState 1)
   (ros::create-nodehandle "op2_group")
   (ros::subscribe "foot_force_sensor/left" geometry_msgs::WrenchStamped #'send self
:lfsr-cb :groupname "op2_group")
   (ros::subscribe "foot_force_sensor/right" geometry_msgs::WrenchStamped #'send self
:rfsr-cb :groupname "op2_group")
   (ros::subscribe "zmp/left" geometry_msgs::Pose2D #'send self :lzmp-cb
:groupname "op2_group")
   (ros::subscribe "zmp/right" geometry_msgs::Pose2D #'send self :rzmp-cb
:groupname "op2_group")
   self)
  (:lfsr-cb (msg) (setq lfsr msg))
  (:rfsr-cb (msg) (setq rfsr msg))
  (:lzmp-cb (msg) (setq lzmp msg))
  (:rzmp-cb (msg) (setq rzmp msg))
  (:state
   (&rest args)
   (case (car args)
         (:lfsr (ros::spin-once "op2_group") lfsr)
         (:rfsr (ros::spin-once "op2_group") rfsr)
         (:lzmp (ros::spin-once "op2_group") lzmp)
         (:rzmp (ros::spin-once "op2_group") rzmp)
         (t (send-super* :state args))))
  (:add-controller (&rest args) nil) ;; currently robotis does not support JTA
  (:angle-vector
   (av &optional (tm 2000))
   (let ((msg (instance sensor_msgs::JointState :init))
         msg-name msg-position (i 0))
     (dolist (j (send robot :joint-list))
       (push (send j :name) msg-name)
       (push (deg2rad (elt av i)) msg-position)
       (incf i))
     (send msg :header :stamp (ros::time-now))
     (send msg :name (nreverse msg-name))
     (send msg :position (nreverse msg-position))
     (ros::publish "controller_joint_states" msg)
     ))
  (:zero-pose
   ()
   (send self
	 :angle-vector
	 (float-vector
	  0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)))
  (:sit-pose
   ()
   (send self 
	 :angle-vector
	 #f(-1.49414 -0.791016 65.5664 -130.342 -72.1582
		     -0.878906 -0.791016 0.878906 -67.0605 129.639
		     70.1367 2.37305 -4.74609 -38.584
		     -14.502 3.51562 37.3535 13.8867 0.703125 5.625)
	 )
   )
  (:reset-pose
   ()
   (send self :angle-vector
	 #f(0 0 20 -40 -20 0 0 0 -20
	      40 20 0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0))
   )
  )

;; test code
(defun init nil
  (setq *ri* (instance robotis_op2-interface :init))
  (setq *robot* (robotis_op2))
  (objects (list *robot*))
  )
(defun demo nil
  (do-until-key
   (send *robot* :angle-vector (send *ri* :state :potentio-vector))
   (when (send *ri* :state :worldcoords)
     (send *robot* :newcoords (send *ri* :state :worldcoords)))
   (send *irtviewer* :draw-objects :flush t)
   (send *robot* :draw-torque *viewer* :torque-vector (send *ri* :state :effort) :flush nil :size 0.5)
   (send *irtviewer* :flush)
   )
  )

(defun demo1 nil
  (do-until-key
   (send *robot* :angle-vector (send *ri* :state :potentio-vector))
   (when (send *ri* :state :worldcoords)
     (send *robot* :newcoords (send *ri* :state :worldcoords)))
   (send *irtviewer* :draw-objects :flush t)
   (send *robot* :draw-torque *viewer* :torque-vector (send *ri* :state :effort) :flush nil :size 0.5)
   (send *robot* :draw-torque *viewer*
	 :torque-vector
	 (coerce (send-all (send *ri* :robot :joint-list) :joint-torque) float-vector)
	 :flush nil :size 1.0)

   (format t "lfsr force=~A lzmp=~A~%"
	   (ros::tf-point->pos (send (send *ri* :state :lfsr) :wrench :force))
	   (float-vector (send (send *ri* :state :lzmp) :x)
			 (send (send *ri* :state :lzmp) :y)))
   (format t "rfsr force=~A rzmp=~A~%"
	   (ros::tf-point->pos (send (send *ri* :state :rfsr) :wrench :force))
	   (float-vector (send (send *ri* :state :rzmp) :x)
			 (send (send *ri* :state :rzmp) :y)))
   (send *irtviewer* :flush)
   )
  )

(defun demo2 nil
  ;;(load "robotis_op2.l")
  (send *robot* :reset-pose)
  (objects (list *robot*))
  (walk-motion *robot*)
  )

(defun demo3 nil
  (do-until-key
   (send *ri* :state)
   (print (send *ri* :robot :rleg :knee-p :joint-torque))
   ))



         
