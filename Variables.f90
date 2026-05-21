MODULE VARIABLES
IMPLICIT NONE

  INTEGER :: Num_RT_Accep = 500
  REAL*8  :: a  = 1.0D0
  REAL*8  :: b  = 1.0D0
  REAL*8  :: T  = 0.2D0
  REAL*8  :: dt = 0.005D0
  REAL*8  :: pert_degree = 0.1D0
  REAL*8  :: x0 = -1. / 2.
  REAL*8  :: xf =  1. / 2.
  INTEGER :: seed = 1
  CHARACTER(LEN=50) :: filename = "React_Traj.dat" 
END MODULE VARIABLES
