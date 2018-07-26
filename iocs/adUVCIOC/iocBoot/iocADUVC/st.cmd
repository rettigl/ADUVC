errlogInit(20000)

< envPaths
#epicsThreadSleep(20)
dbLoadDatabase("$(TOP)/dbd/adUVCApp.dbd")
adUVCApp_registerRecordDeviceDriver(pdbbase) 

# Prefix for all records
epicsEnvSet("PREFIX", "XF:10IDC-BI{UVC-Cam:1}")
# The port name for the detector
epicsEnvSet("PORT",   "UVC1")
# The queue size for all plugins
epicsEnvSet("QSIZE",  "30")
# The maximim image width; used for row profiles in the NDPluginStats plugin
epicsEnvSet("XSIZE",  "256")
# The maximim image height; used for column profiles in the NDPluginStats plugin
epicsEnvSet("YSIZE",  "256")
# The maximum number of time seried points in the NDPluginStats plugin
epicsEnvSet("NCHANS", "2048")
# The maximum number of frames buffered in the NDPluginCircularBuff plugin
epicsEnvSet("CBUFFS", "500")
# The search path for database files
epicsEnvSet("EPICS_DB_INCLUDE_PATH", "$(ADCORE)/db")
#epicsThreadSleep(15)

#/*
# * Constructor for ADUVC driver. Most params are passed to the parent ADDriver constructor. 
# * Connects to the camera, then gets device information, and is ready to aquire images.
# * 
# * @params: portName -> port for NDArray recieved from camera
# * @params: serial -> serial number of device to connect to
# * @params: framerate -> framerate at which camera should operate
# * @params: maxBuffers -> max buffer size for NDArrays
# * @params: maxMemory -> maximum memory allocated for driver
# * @params: priority -> what thread priority this driver will execute with
# * @params: stackSize -> size of the driver on the stack
# */


# ADUVCConfig(const char* portName, const char* serial, int framerate, int maxBuffers, size_t maxMemory, int priority, int stackSize)
ADUVCConfig("$(PORT)", "serialNumber", 30,  0, 0, 0, 0)
epicsThreadSleep(2)

asynSetTraceIOMask($(PORT), 0, 2)
#asynSetTraceMask($(PORT),0,0xff)

dbLoadRecords("$(ADCORE)/db/ADBase.template", "P=$(PREFIX),R=cam1:,PORT=$(PORT),ADDR=0,TIMEOUT=1")
dbLoadRecords("$(ADUVC)/db/ADUVC.template","P=$(PREFIX),R=cam1:,PORT=$(PORT),ADDR=0,TIMEOUT=1")
#
# Create a standard arrays plugin, set it to get data from Driver.
#int NDStdArraysConfigure(const char *portName, int queueSize, int blockingCallbacks, const char *NDArrayPort, int NDArrayAddr, int maxBuffers, size_t maxMemory,
#                          int priority, int stackSize, int maxThreads)
NDStdArraysConfigure("Image1", 3, 0, "$(PORT)", 0)
#dbLoadRecords("$(ADCORE)/db/NDPluginBase.template","P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),NDARRAY_ADDR=0")
#dbLoadRecords("$(ADCORE)/db/NDStdArrays.template", "P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,TYPE=Int16,SIZE=16,FTVL=SHORT,NELEMENTS=802896")
dbLoadRecords("$(ADCORE)/db/NDStdArrays.template", "P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,NDARRAY_PORT=$(PORT),TIMEOUT=1,TYPE=Int16,FTVL=SHORT,NELEMENTS=1000000")
#
# Load all other plugins using commonPlugins.cmd
< $(ADCORE)/iocBoot/commonPlugins.cmd
#
#Note mpi control pipe out & in reversed.  Names are from the view of the MPI program.
#NDPipeWriterConfigure("PipeWriter1", 15000, 0, "$(PORT)", "/local/xpcscmdout", "/local/xpcscmdin", 0, 0, 0, 0,0)
#dbLoadRecords("$(ADCORE)/db/NDPluginPipeWriter.template", "P=$(PREFIX),R=PW1:,  PORT=PipeWriter1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),CMD_IN_PORT=PW_CMD_IN,CMD_OUT_PORT=PW_CMD_OUT")

#Note Local plugin to run the IMM plugin writer
#NDFileIMMConfigure("IMM1", 15000, 0, "$(PORT)",  0, 0, 0)
#dbLoadRecords("$(ADCORE)/db/NDFileIMM.template", "P=$(PREFIX),R=IMM1:,PORT=IMM1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT)")

set_requestfile_path("$(ADUVC)/adUVCApp/Db")

#asynSetTraceMask($(PORT),0,0x09)
#asynSetTraceMask($(PORT),0,0x11)
iocInit()

# save things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=$(PREFIX)")