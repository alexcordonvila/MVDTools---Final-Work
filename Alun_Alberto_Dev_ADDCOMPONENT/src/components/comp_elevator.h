#pragma once
#include "../src/Components.h"
//#include "../extern.h"
struct comp_elevator : Component
{
	int my_ent_id;
	int speed;
	lm::vec3 direction;
	bool no_Automatic = false;

	lm::vec3 axis;
	// Data manipulation methods
	void Load(rapidjson::Value & entity, int ent_id);

	void update(float dt);
	void debugRender();
};