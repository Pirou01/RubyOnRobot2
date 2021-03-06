class Timer
  ##
  # This class handle all the command that are +time+ linked.
  #
  # This is the entry point of the timer. All action are launch from here
  # For understanding what's hapenned, I've put a speacial +logger+.
  # Look in log/timer.log

  # This is the entry point of all regulation
  def self.execute
    @robot = Robot.first
    @robot.read_all


    if @robot.is_actif?
      if @robot.has_perturbation?
        # si il y a une opération actuelle, on la met en échoué
        @robot.current_operation.failed if @robot.has_current_operation?

        # On effectue l'action le robot le temps max de la perturbation.
        if @robot.has_next_operation?
          WorkingOperation.new(:robot => @robot, :operation => @robot.active_perturbation.operation, :status => 'IDLE').insert_at(@robot.next_operation.position)
        else
          @robot.active_perturbation.operation.enqueue_top
        end

        next_operation = @robot.next_operation # effectue
        next_operation.perform
        sleep next_operation.operation.time_max # fait dormir
      else
        if @robot.has_current_operation? or @robot.has_next_operation?

          if !@robot.has_current_operation? and @robot.has_next_operation?
            # on envoie la prochaine opération si il y en a une
            @robot.next_operation.perform
          else
            if @robot.current_operation.state_reached?
              @robot.current_operation.finished
              @robot.next_operation.perform if @robot.next_operation
            else
              if @robot.current_operation.timeout?
                  if @robot.current_operation.has_operation_error?
                    WorkingOperation.new(:robot => @robot, :operation => @robot.current_operation.operation.operation_error, :status => 'IDLE').insert_at(@robot.current_operation.position+1)
                  end
                @robot.current_operation.failed

                @robot.next_operation.perform if @robot.has_next_operation?
              end
            end
          end
        end
      end
    end
  end
end