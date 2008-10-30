# CMake module which checks for python and some its modules
# there is a two-stage support for python:
# - 


FIND_PACKAGE(PythonLibs) # MapServer export tool
FIND_PACKAGE(PythonInterp) # test for sip and PyQt4


MACRO (TRY_RUN_PYTHON RESULT CMD)
  IF (PYTHONINTERP_FOUND)
    
    EXEC_PROGRAM(${PYTHON_EXECUTABLE} ARGS -c "\"${CMD}\""
                 OUTPUT_VARIABLE out
                 RETURN_VALUE retval)
    
    # optional last parameter to save the output
    SET (OUTPUT ${ARGV2})
    IF (OUTPUT)
      SET(${OUTPUT} ${out})
    ENDIF (OUTPUT)
    
    IF (retval EQUAL 0)
      SET (${RESULT} TRUE)
    ELSE (retval EQUAL 0)
      SET (${RESULT} FALSE)
    ENDIF (retval EQUAL 0)
  
  ELSE (PYTHONINTERP_FOUND)
    SET (${RESULT} FALSE)
  ENDIF (PYTHONINTERP_FOUND)
ENDMACRO (TRY_RUN_PYTHON)

# enable/disable python support (mapserver export tool and bindings)
IF (PYTHON_LIBRARIES AND PYTHON_INCLUDE_PATH)
  SET (PYTHON_FOUND TRUE)
  MESSAGE(STATUS "Python libraries found")

  # TODO: should not be needed, report it to CMake devs
  IF (UNIX AND NOT APPLE)
    SET (PYTHON_LIBRARIES ${PYTHON_LIBRARIES} util)
  ENDIF (UNIX AND NOT APPLE)
  
  # check for SIP
  TRY_RUN_PYTHON (HAVE_SIP_MODULE "from sip import wrapinstance")
  
  IF (APPLE)
    SET (SIP_MAC_PATH
      /System/Library/Frameworks/Python.framework/Versions/2.5/bin
      /System/Library/Frameworks/Python.framework/Versions/2.4/bin
      /System/Library/Frameworks/Python.framework/Versions/2.3/bin)
  ENDIF (APPLE)

  FIND_PROGRAM (SIP_BINARY_PATH sip PATHS ${SIP_MAC_PATH})
  
  IF (HAVE_SIP_MODULE AND SIP_BINARY_PATH)
    # check for SIP version
    # minimal version is 4.4
    SET (SIP_MIN_VERSION 040400)
    TRY_RUN_PYTHON (RES "import sip\nprint '%x' % sip.SIP_VERSION" SIP_VERSION)
    IF (SIP_VERSION EQUAL "${SIP_MIN_VERSION}" OR SIP_VERSION GREATER "${SIP_MIN_VERSION}")
      SET (SIP_IS_GOOD TRUE)
    ENDIF (SIP_VERSION EQUAL "${SIP_MIN_VERSION}" OR SIP_VERSION GREATER "${SIP_MIN_VERSION}")
    
    IF (NOT SIP_IS_GOOD)
      MESSAGE (STATUS "SIP is required in version 4.4 or later!")
    ENDIF (NOT SIP_IS_GOOD)
  ELSE (HAVE_SIP_MODULE AND SIP_BINARY_PATH)
    MESSAGE (STATUS "SIP not found!")
  ENDIF (HAVE_SIP_MODULE AND SIP_BINARY_PATH)
  
  # if SIP and PyQt4 are found, enable bindings
  IF (SIP_IS_GOOD)
    SET (HAVE_PYTHON TRUE)
    MESSAGE(STATUS "Python bindings enabled")
  ELSE (SIP_IS_GOOD)
    SET (HAVE_PYTHON FALSE)
    MESSAGE(STATUS "Python bindings disabled due dependency problems!")
  ENDIF (SIP_IS_GOOD)
  
ENDIF (PYTHON_LIBRARIES AND PYTHON_INCLUDE_PATH)