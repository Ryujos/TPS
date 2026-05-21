MODULE WRITE_REACTION_TRAJECTORY

  USE EQUATIONS

IMPLICIT NONE

CONTAINS


  SUBROUTINE Start_Output()
 
     OPEN(1, file="React_Traj.dat", status="new")
 
     WRITE(1,*) "Reaction Trajectory"
     WRITE(1,*) "Position (x)             Potential     (V)"
 
     CLOSE(1)
 
  END SUBROUTINE Start_Output

  SUBROUTINE Write_React_Traj(a,b,x)

    REAL*8 :: Pot
    REAL*8, INTENT(IN) :: a,b,x

    Pot = Calc_Potential(a,b,x)

    OPEN(1, file="React_Traj.dat", status="old", position="append")          

    WRITE(1,*) x, Pot

    CLOSE(1)

  END SUBROUTINE Write_React_Traj

END MODULE WRITE_REACTION_TRAJECTORY
