#include "comp_elevator.h"
#include "../extern.h"

void comp_elevator::Load(rapidjson::Value & entity, int ent_id)
{
	my_ent_id = ent_id;
	auto jsondirection = entity["elevator"]["direction"].GetArray();
	auto jsonspeed = entity["elevator"]["Velocitat"].GetFloat();
	auto jsonAutomatic = entity["elevator"]["Automatic"].GetBool();
	this->speed = jsonspeed;
	direction.x = jsondirection[0].GetFloat();
	direction.y = jsondirection[1].GetFloat();
	direction.z = jsondirection[2].GetFloat();
	no_Automatic = jsonAutomatic;
}

void comp_elevator::update(float dt)
{
	// Update object speed per frame
	Transform* transform;
	transform = &ECS.getComponentFromEntity<Transform>(my_ent_id);
	//transform->translate(speed * direction.x * dt, speed * direction.y  * dt, speed * direction.z * dt);
	transform->translate(speed * direction.x * dt, speed * direction.y * dt, speed * direction.z * dt);
	
	if(direction.y != 0){ //Si soy una plataforma vertical
		if ((transform->position().y > 13 || transform->position().y < 0)) {
			speed = speed * -1;
		}
	}
	if (direction.x != 0) { //Si soy una plataforma horizontal
		if ((transform->position().x < 20 || transform->position().x > 50)) {
			speed = speed * -1;
		}
	}
	

}

void comp_elevator::debugRender()
{
	float speed_[1] = { speed };
	lm::vec3 dir = this->direction;
	float dir_array[3] = { dir.x,dir.y,dir.z };

	ImGui::AddSpace(0, 5);
	{
		if (ImGui::TreeNode("Elevator")) {
			ImGui::AddSpace(0, 5);
			ImGui::SliderFloat("Elevator Speed", speed_, 0, 4 );
			//ImGui::Text(speed);
			ImGui::AddSpace(0, 5);
			
			if (ImGui::DragFloat3("Direction", dir_array)) {
				//this->axis = (axis_array[0], axis_array[1], axis_array[2]);
			}
			ImGui::AddSpace(0, 5);
			ImGui::Checkbox("Automatic", &no_Automatic);
			//}
			ImGui::TreePop();
		}
	}
}