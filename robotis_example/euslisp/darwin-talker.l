#!/usr/bin/env roseus
;;;
;;; euslisp version of ros_tutorials/rospy_tutorials/001_talker_listener
;;;

(ros::load-ros-manifest "roseus")
;;;

;;;
;;;
(ros::roseus "darwin-talker")
(ros::advertise "controller_joint_states" sensor_msgs::JointState 10)

(ros::rate 100)
(setq i 0)

(do-until-key
 (if (not (ros::ok)) (print "ros::not ok"))
 (setq msg (instance sensor_msgs::JointState :init))
 (send msg :name (list "head_pan"))
 (setq v (* (/ pi 6.0) (sin (deg2rad i))))
 (send msg :position (float-vector v))
 ;;(send msg :velocity (float-vector 0.0))
 ;;(send msg :effort (float-vector 0.0))
 (print v)
 (ros::publish "controller_joint_states" msg)
 (ros::sleep)
 (incf i)
 (if (> i 360) (setq i 0))
 )

;;(ros::roseus "shutdown")
;;(exit)

