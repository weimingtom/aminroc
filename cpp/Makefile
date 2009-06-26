# Developed by AminLab
# ------------------------------------
# date:2009-06-02
# site:http://www.aminlab.cn
# ------------------------------------
#*********************************************************************************
#
#	��Ŀ����
#
#*********************************************************************************
# ������
CXX			:= g++
CC			:= gcc
# ����Ŀ¼
BIN_PATH		:= ../bin/
# �����ļ���
BIN_NAME		:= Roc.bin
# ��ʱ�ļ���
TEMP_PATH		:= tmp/
# ֧�ֵĲ���ϵͳ�б�
PLATFORMS		:= linux,FreeBSD
# ���������ļ�
INCS			:=
# ������
LIBS			:= -lpthread
# �����ļ��б�
OBJS			:= $(patsubst %.cpp,%.o,$(wildcard src/*.cpp))
OBJS_AL			:= $(patsubst %.cpp,%.o,$(wildcard com/al/src/*.cpp))
OBJS_LUA		:= $(patsubst %.c,%.o,$(wildcard com/lua5.1.4/src/*.c))
OBJS_TINYXML	:= $(patsubst %.cpp,%.o,$(wildcard com/tinyxml2.5.3/src/*.cpp))
#*********************************************************************************
#
#	�������(�����GNU make�ĵ��������޸�)
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
	
# ������
#---------------------
clean:
	rm -f $(TEMP_PATH)*.o

# ��������
#---------------------
run:
	cd $(BIN_PATH);./$(BIN_NAME)