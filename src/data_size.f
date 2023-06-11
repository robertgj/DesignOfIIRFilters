c     Compile with gfortran src/data_size.f -o data_size
c     Compare with options -fdefault-real-8 and/or -fdefault-integer-8
      INTEGER :: x
      REAL :: y
      DOUBLEPRECISION :: z
      PRINT *,SIZEOF(x) 
      PRINT *,SIZEOF(y)
      PRINT *,SIZEOF(z)
      END 
