#include "Config.h"

bool Config::load(const char* file_name)
{
	PRINT_ITEM("file",file_name);

	TiXmlDocument xml;

	if(!xml.LoadFile(file_name)){
		PRINT_ERROR("invalid file:" << file_name);
		return false;
	}

	TiXmlElement* root = xml.RootElement();

	if(root == NULL){
		PRINT_ERROR("null root node");
		return false;
	}

	TiXmlElement* childElement = root->FirstChildElement();

	while(childElement != NULL)
	{
		const char* value = childElement->Value();
		const char* text = childElement->GetText();
		mapTree[value] = text;

		childElement = childElement->NextSiblingElement();
	}

	return true;
}
