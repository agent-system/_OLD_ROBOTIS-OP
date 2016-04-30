;;;
(load "package://pr2eus/robot-interface.l")
(load "robotis_op2.l")

(defclass robotis_op2-interface
  :super robot-interface
  :slots ())

(defmethod robotis_op2-interface
  (:init
   (&rest args &key (robot robotis_op2-robot))
   (send-super* :init :robot robot :joint-states-topic "robot_joint_states" args)
   (ros::advertise "controller_joint_states" sensor_msgs::JointState 1)
   self)
  (:add-controller (&rest args) nil) ;; currently robotis does not support JTA
  (:angle-vector
   (av &optional tm)
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
  )

;; test code
(setq *ri* (instance robotis_op2-interface :init))
(setq *robot* (robotis_op2))
(objects (list *robot*))
(do-until-key
 (send *robot* :angle-vector (send *ri* :state :potentio-vector))
 (if (send *ri* :state :worldcoords)
     (send *robot* :newcoords (send *ri* :state :worldcoords))
   (format t "(send *ri* :state :worldcoords)=nil~%"))
 (send *irtviewer* :draw-objects :flush t)
 (send *robot* :draw-torque *viewer* :torque-vector (send *ri* :state :effort) :flush nil :size 1)
 (send *irtviewer* :flush)
 )
