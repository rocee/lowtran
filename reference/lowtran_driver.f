! Comments by Michael Hirsch, Ph.D. https://www.scivision.co
! p. = page, s. = section of Lowtran7 user manual
! p. 19(28) s. 3.1 begins to describe the Card format
! Remember that:
!  * Fortran is case-insensitive:   XY = xy = Xy = xY
!  * Fortran ignores spaces, punctuation is all that matters.
!  * Fortran 77 can only have program text in columns 7..72
!  * Fortran 77 comments must start in column 1 or >= 7
!  * Fortran 77 columns 2-5 for line numbers, column 6 for continuation symbol
      Program LowtranDemo

      implicit none

      integer imodel,nargin,i
      character(len=8) :: arg
      integer :: model,itype,iemsct,im
      integer :: iseasn,ird1
      integer :: iday,ro,isourc
      real :: angle,h1,range,v1,v2,dv

!     Python .true.:   Use common blocks (from f2py)
!     Python .false.: Read the Tape5 file (like it's the 1960s again)
      logical, parameter :: Python= .true.

! Model bounds and resolution (can't increase resolution beyond model limits)
      integer, Parameter :: nwl = 51  ! number of wavelengths
      integer, Parameter :: ncol = 63  ! number of columns in output
! currently unused variables (don't have to be parameter)
      real, parameter :: H2=0. ! only used for IEMSCT 1 or 2

      ! these are ignored for auroral case
      integer, parameter ::  ml=1 !1: one level of horiz atmosphere (as per lowtran manual for this sim)
      real :: ZMDL(ml),P(ml),T(ml), WMOL(12)

      real :: TXPy(nwl,ncol), VPy(nwl), ALAMPy(nwl), TRACEPy(nwl),
     &      UNIFPy(nwl), SUMAPy(nwl), IrradPy(nwl,2)

! Model configuration, see Lowtran manual p. 21(30) s. 3.2

! Command line selection
      imodel=0
      nargin = command_argument_count()
      if (nargin.ge.1) then
        call GET_COMMAND_ARGUMENT(1,arg); read(arg,*) imodel
      endif
 
      if (imodel.eq.0) then
          v1=8333.; v2=33333. ! frequency cm^-1 bounds
          dv=500. ! DV: frequency cm^1 step (lower limit 5. per Card 4 p.40)

!!! Auroral oval Model e.g. central Alaska !!!
          model =5 ! 5: subarctic winter
          itype=3 ! 3: vertical or slant path to space
          iemsct=0! 0: transmittance model
          im=0 !0: normal operation (no custom user conditions)

          iseasn=0 ! 0: default for this type redirects to 1: spring/summer
          IRD1=0 !0: not used

          ! ZMDL, P, T not used -- don't care about uninitialized value

          ANGLE=0. ! initial zenith angle; in Python set to camera boresight angle (for our cameras typically magnetic inclination of E-layer ionosphere, e.g. angle is about 12.5 at Poker Flat Research Range)
          h1=0. ! our cameras are at ground level (kilometers)
! in lowtran7.f, I set M1-M6, MDEF all =0 per p.21
          range=0. ! not used
      elseif (imodel.eq.1) then
!!! Horizontal model (only way to use meterological data) !!!
          v1=714.2857; v2=1250. ! frequency cm^-1 bounds
          dv=13.  ! DV: frequency cm^1 step (lower limit 5. per Card 4 p.40)

          model=0 ! 0: Specify meterological data (horiz path)
          itype=1 ! 1: Horizontal, constant pressure path
          iemsct=0 ! 0: transmittance model
          im=1 ! 1: horizontal path: p.42 of manual

          iseasn=0 !0: default for this type redirects to 1: spring/summer
          ird1=1 !1: use card 2C2

! TODO M1-M6=0 to use JCHAR of card 2C.1 (p.22)
          h1 = 0.05  !(kilometers altitude of horizontal path)
          angle = 0. ! TODO truthfully it's 90. for horizontal path, have to check/test to see if Lowtran uses this value for model=0 horiz. path.
          range=h1
          zmdl(1) = h1
          P(1) = 949 ! millibar
          T(1) = 283.8 ! Kelvin
          WMOL = [93.96,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.]
      elseif (imodel.eq.2) then
!!! Solar irradiance !!!
          v1=714.2857; v2=1250. ! frequency cm^-1 bounds
          dv=13.  ! DV: frequency cm^1 step (lower limit 5. per Card 4 p.40)
        
          model = 2 ! 2: midlatitude summer, 3: mid latitude winter
          itype = 3 ! 3: slant to space (required by iemsct=3)
          iemsct = 3 !3: directly transmitted solar irradiance, 2: scattered radiance,...
          im=0

          iseasn=0
          ird1=0

          h1 = 0.05
          angle = 0. ! arbitrary, zenith angle
          iday = 0 ! 0: use mean earth-sun distance
          ro = 0 ! 0: use model earth radius
          isourc = 0 ! 0: sun, 1: moon

          ! Cards 3A, 3B not used for irradiance
    
      else
         error stop 'unknown model selection'
      endif
!-------- END model config -----------------
!-------- END command line parse ------------

        call LWTRN7(Python,nwl,V1,V2,DV,
     &  TXPy,VPy,ALAMPy,TRACEPy,UNIFPy, SUMAPy,irradpy,
     &  MODEL,ITYPE,IEMSCT,IM,
     &  ISEASN,ML,IRD1,
     &  ZMDL,P,T,WMOL,
     &  H1,H2,ANGLE,range)
!--- friendly output

      print *,'wavelengths[nm]   transmission    TransIrradiance  ETIrr'

        do i = 1,nwl
            print *, 1e3*ALAMPy(i), TXPy(i,9),IrradPy(i,1),irradpy(i,2)
        enddo

        end program

! 
!------------ obsolete ------------
!        Block Data setcards
!        Integer   MODEL,ITYPE,IEMSCT,M1,M2,M3,IM,NOPRT,M4,M5,M6,MDEF
!     &    IRD1,IRD2
!        Real      TBOUND,SALB,H1,H2,ANGLE,RANGE,BETA,RE
!
!        Common /CARD1/MODEL,ITYPE,IEMSCT,M1,M2,M3,IM,NOPRT,TBOUND,SALB
c        Data Model/5/, ITYPE/3/, IEMSCT/0/, M1/0/,M2/0/,M3/0/,NOPRT/0/,
c     &       TBOUND/0/,SALB/0/
c
c        COMMON /CARD1A/ M4,M5,M6,MDEF,        IRD1,IRD2
c        Data M4/0/,M5/0/,M6/0/,MDEF/0/ !No need to init IRD1,IRD2
c
c        COMMON /CARD2/ IHAZE,ISEASN,IVULCN,ICSTL,ICLD,IVSA,VIS,WSS,WHH,
c     &    RAINRT
c        DATA IHAZE/0/  !no need for the rest
c
c        COMMON /CARD3/ H1,H2,ANGLE,RANGE,BETA,RE,LEN
c        Data H1/0./,H2/0./,Angle/0./
c
c       COMMON /CARD4/ V1,V2,DV
c        Data V1/8333./, V2/33333./, DV/500./
c
c        End Block Data setcards
