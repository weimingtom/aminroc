# Developed by AminLab
# ------------------------------------
# date:2009-06-02
# site:http://www.aminlab.cn
# ------------------------------------
#*********************************************************************************
#
#	项目配置
#
#*********************************************************************************
# 编译器
CXX			:= g++
CC			:= gcc
# 生成目录
BIN_PATH		:= ../bin/
# 生成文件名
BIN_NAME		:= Roc.bin
# 临时文件夹
TEMP_PATH		:= tmp/
# 支持的操作系统列表
PLATFORMS		:= linux,FreeBSD
# 附带包含文件
INCS			:=
# 附带库
LIBS			:= -lpthread
# 编译文件列表
OBJS			:= $(patsubst %.cpp,%.o,$(wildcard src/*.cpp))
OBJS_AL			:= $(patsubst %.cpp,%.o,$(wildcard com/al/src/*.cpp))
OBJS_LUA		:= $(patsubst %.c,%.o,$(wildcard com/lua5.1.4/src/*.c))
OBJS_TINYXML	:= $(patsubst %.cpp,%.o,$(wildcard com/tinyxml2.5.3/src/*.cpp))
#*********************************************************************************
#
#	编译规则(请查阅GNU make文档后再行修改)
#
#*********************************************************************************
choose:
	@echo ""
	@echo "Compile need with a parameter of system name(like 'make linux')"
	@echo "  -support system:$(PLATFORMS)"
	@echo ""
	
linux:$(OBJS) $(OBJS_AL) $(OBJS_LUA) $(OBJS_TINYXML)
	$(CXX) -o $(BIN_PATH)$(BIN_NAME) $(addprefix $(TEMP_PATH),$(notdir $^)) $(INCS) $(LIBS)

FreeBSD:$(OBJS) $(OBJS_AL) $(OBJS_LUA) $(OBJS_TINYXML)
	$(CXX) -o $(BIN_PATH)$(BIN_NAME) $(addprefix $(TEMP_PATH),$(notdir $^)) $(INCS) $(LIBS) -lcompat

%.o : %.cpp
	${CXX} -c $< -o $(TEMP_PATH)$(notdir $@)

%.o : %.c
	${CC} -c $< -o $(TEMP_PATH)$(notdir $@)
	
# 清命令
#---------------------
clean:
	rm -f $(TEMP_PATH)*.o

# 运行命令
#---------------------
run:
	cd $(BIN_PATH);./$(BIN_NAME)
