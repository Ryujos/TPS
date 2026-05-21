      function gauss()
      REAL*8  U1, U2, V1, V2, X1, X2, S, gauss

 10   continue
      U1 = r1279()
      U2 = r1279()
      V1 = 2.*U1 - 1.
      V2 = 2.*U2 - 1.
      S = V1**2 + V2**2
      IF (S.GE.1.) GOTO 10
      X1 = V1*SQRT(-2.*LOG(S)/S)
      X2 = V2*SQRT(-2.*LOG(S)/S)         
      gauss=x1
      return 
      END
