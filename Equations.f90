MODULE EQUATIONS

IMPLICIT NONE

CONTAINS

!------------------------------------------------------
! Computing of the POTENTIAL
!------------------------------------------------------


  REAL*8 FUNCTION Calc_Potential(a,b,x)
    REAL*8 :: a,b,x
    
    Calc_Potential = a*(x**4 - b*x**2)

  END FUNCTION Calc_Potential


!-----------------------------------------------------
! Computing of the NEW POSITION
!-----------------------------------------------------

  !------------------------------
  ! INTEGRATION BACKWARD IN TIME
  !------------------------------

  REAL*8 FUNCTION Calc_New_Pos_Back(x,a,b,T,dt,rand)
    IMPLICIT NONE  
    REAL*8 :: Det_Part,Stoc_Part
    REAL*8 :: x,a,b,T,dt,rand
  
    Det_Part = Calc_Det_Part(a,b,x,dt)
    Stoc_Part = Calc_Stoc_Part(T,dt,rand)
  
    Calc_New_Pos_Back = x - Det_Part + Stoc_Part

  END FUNCTION Calc_New_Pos_Back

  !-----------------------------
  ! INTEGRATION FORWARD IN TIME
  !-----------------------------

  REAL*8 FUNCTION Calc_New_Pos_Forw(x,a,b,T,dt,rand)
    IMPLICIT NONE
    REAL*8 :: Det_Part,Stoc_Part
    REAL*8 :: x,a,b,T,dt,rand

    Det_Part = Calc_Det_Part(a,b,x,dt)
    Stoc_Part = Calc_Stoc_Part(T,dt,rand)

    Calc_New_Pos_Forw = x - Det_Part + Stoc_Part

  END FUNCTION Calc_New_Pos_Forw

  !-----------------------------------
  ! DETERMINISTIC PART OF THE DYNAMIC
  !-----------------------------------

  REAL*8 FUNCTION Calc_Det_Part(a,b,x,dt)

    REAL*8 :: a,b,x,dt

    Calc_Det_Part = 2*a * (2*x**3 - b*x) * dt

  END FUNCTION Calc_Det_Part

  !--------------------------------
  ! STOCHASTIC PART OF THE DYNAMIC
  !--------------------------------

  REAL*8 FUNCTION Calc_Stoc_Part(T,dt,rand)

    REAL*8 :: T,dt,rand

    Calc_Stoc_Part = SQRT(2*T*dt) * rand

  END FUNCTION Calc_Stoc_Part

END MODULE EQUATIONS
