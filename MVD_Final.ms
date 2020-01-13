global size = 100
global density = 15
global treeDensity = 120
global randomTerrain = undefined 
global randomRoad = undefined 
global caroffset = undefined
heapSize += 2000000
delete $*

-- We create the random terrain given the parameters
function createRandomTerrain size density = (
	
	myplane = Plane width:size length:size lengthsegs:density widthsegs:density wirecolor:brown
	myplane = convertToPoly(myplane)
	
	addmodifier myplane (NoiseModifier())
	myplane.modifiers[#noise].scale = size * 0.01
	myplane.modifiers[#noise].strength = [0,0,4.1]
	myplane.modifiers[#noise].seed = (random 1 1000)
	myplane.name = "Ground"
		
	return myplane
)

-- Define the spline for the road
function drawSpline knots size density = (
	
	-- We want to create an spline
	-- With initial and end points provided.
	ss = SplineShape pos:[0,0,0] render_renderable:true render_displayRenderMesh:true render_rectangular:true render_viewport_rectangular:true
	ss.render_length = 3
	ss.render_width = 3.5
	addNewSpline ss
	
	for i in knots do (
		addKnot ss 1 #smooth #curve i
	)

	updateShape ss
	minimumDistance = (size / density) * 0.5
	newRoad = conformRoad ss minimumDistance
	return newRoad
)

function conformRoad road minDistance = (
	
	ss = SplineShape pos:[0,0,0] render_renderable:true render_displayRenderMesh:true render_rectangular:true render_viewport_rectangular:true
	ss.render_length = 1
	ss.render_width = 4
	addNewSpline ss
	
	lengthTotal = curveLength road
	stepsTotal = (lengthTotal / minDistance) as Integer
	
	for i = 1 to stepsTotal do (
		
		-- Interpolate along the spline "road"
		-- get a position on each step 'i'
		currentInterp = ((i as float) / (stepsTotal as float))
		pos = lengthInterp road currentInterp
		
		-- Raycast to the terrain and get the raycasted hit positon
		ray_dir = Ray (pos + [0,0,1000]) [0,0,-1]
		ray_int = intersectRay randomTerrain ray_dir
		
		-- In case we have an intersection, then change the position of the knot
		-- We are not handling other situations were there is no collision
		if ray_int != undefined then (
			pos = ray_int.pos
		)
		
		-- add the knot to the set
		addKnot ss 1 #smooth #curve pos
	)
	
	updateShape ss
	ss.name = "TheRoad"
	ProBoolean.createBooleanObjects $Ground road 2 0 0
	converttopoly($Ground)
	--delete road
	return ss
)

-- Create trees along spline (not colliding between them or with the road) (ex c)
function createRandomTrees amount density = (	
	-- Loop through random road
	-- Interpolate through it given the density as step
	-- Places trees along the spline given the amount provided
	-- Filling spline surroundings with props
roadOffset = $theRoad.render_width	
density = density as float


for i = 0 to density do 
(	
	road_point = lengthInterp randomRoad (i/density)
	road_tangent = lengthtangent randomRoad 1 (i/density)
	road_off_dir = cross road_tangent  [0,0,1]
	new_pos1 = road_point + (random (roadOffset + 1) (roadOffset + 8)) * road_off_dir
	new_pos2 = road_point - (random (roadOffset + 1) (roadOffset + 8)) * road_off_dir
	b1 = Foliage name:("prop_" + i as string) height:6 density:1 pos:new_pos1 scale:[0.5,0.5,0.5] CanopyMode: 3
	b2=  Foliage name:("prop_" + i as string) height:6 density:1 pos:new_pos2 scale:[0.5,0.5,0.5] CanopyMode: 3
	oldb1 = b1

	--Realocation of the trees if they do not touch the floor
	ray_dir = Ray b1.position [0,0,-1]
	ray_dir2 = Ray b2.position [0,0,-1]
	ray_int = intersectRay $Ground  ray_dir
	ray_int2 = intersectRay $Ground  ray_dir2
		if ray_int != undefined then
	(
		b1.pos = ray_int.pos
	)else(
		delete b1
		
	)
	if ray_int2 != undefined then
	(
		b2.pos = ray_int2.pos
	)else(
		delete b2
		
	)
/*
	colision = collisionDetection b1 oldb1
	if colision then (
		delete b1
		print "Collision"
	)
	
	colision = collisionDetection b2 oldb2
	if colision then (
		delete b2
		
	)*/
)

)
--Check if a tree is colidiing with a sceen object
/*function collisionDetection tree= (
	for i = 0 to $myDumy.children.count do 
	(
		if intersects tree $myDumy.children[i] then 
			col = true		
		else
			col = false
	)
	return 	col
)*/
/*
function collisionDetection tree= (
	for i = 0 to $myDumy.children.count do 
	(
		if intersects tree $myDumy.children[i] then 
			col = true		
		else
			col = false
	)
	return 	col
)
	ray_dir = Ray (pos + [0,0,1000]) [0,0,-1]
	ray_int = intersectRay randomTerrain ray_dir
*/
-- Create the car animation and camera animation (d & e)
function createAnimationCar spent = (
	theRoad = $TheRoad

	--Here we store all the spline points
	roadArray = #()
	
	
	--Get the Spline points to create the animation
	for s = 1 to (numsplines theRoad) do(
			for k = 1 to (numknots theRoad s) do (
				--format "spline_%_knot_%_pos = %\n" s k (getKnotPoint theRoad s k)
				nextpoint = getKnotPoint theRoad s k
				--print nextpoint
				append roadArray nextpoint
			)
	)
	--Get the first point of the Spline "road"
    start = roadArray[4]
	myDummy = Dummy name:"myDumy" scale:[0.1,0.1,0.1]
	--myDummy.pos = roadArray[4]
	--Convert the road into mesh
	converttopoly($TheRoad)
	-- Create a car or use -- ImportFile "audi_car.obj" #noPrompt
	ImportFile "E:\Master\Tools_FinalDelivery\car.fbx" #noPrompt using:FBXIMP 
	--animcar.wirecolor = color (255,255,255)
	animCar = $Object010
	animCar.name = "Car"
	animCar.scale = [1,1,1]
	animCar.pos = start
	
	-- create a camera to follow the car
	cam = FreeCamera name:"Cam" pos:[0,0,0] type:#target isselected:on
	cam.type = #target
	
	cam.Target.parent = myDummy
	cam.targetDistance = distance cam.pos myDummy.pos
	-- Place the car and the camera on road start
	animCar.pos = start + [0,0,15]
	converttopoly(animCar)
	caroffset = animCar.pos;
	ray_dir = Ray animCar.position [0,0,-1000]
	ray_int = intersectRay $TheRoad ray_dir
	if ray_int != undefined then
	(
		caroffset = ray_int.pos
	)
	-- Attach the camera to the car with proper orientation
	viewport.setCamera cam
	local n = 1
	local j = 2

animate on for t = 0 to spent by 5
do at time t
(
	at time t  
	-- Interpolate along the road spline
	-- Set a keyframe of my car position at given time
	cam.pos = roadArray[n] + [-15,-15,10+caroffset.z]
	animCar.pos = roadArray[n] + [0,0, caroffset.z]
	myDummy.pos = roadArray[j] + [0,0, caroffset.z]
	-- Set a keyframe of my car rotation at given time
	
	animCar.rotation.controller = LookAt_Constraint ()
	
	animCar.rotation.controller.appendTarget $myDumy 50.0 
	animCar.rotation.controller.upnode_ctrl = 1
	animCar.rotation.controller.StoUP_axis = 1
	-- lengthtangent to get the tangent direction
	
		
	-- Camera must follow the car
	
	if n < (roadArray.count) then(
		n = n + 1
	)
	if j < (roadArray.count-1) then(
		j = j + 1
	)		
	)
)

-- Determine initial knots of the spline and retrieve general information
function createRandomRoad size density = (
	
	totalFaces = polyop.getNumFaces randomTerrain
	step = totalfaces * 0.25

	marginStep = (size + (random 2 (size - 2)))
	pStart 	= polyop.getFaceCenter randomTerrain 1
	pEnd 	= polyop.getFaceCenter randomTerrain totalFaces
	pMid1 	= polyop.getFaceCenter randomTerrain (random marginStep step)
	pMid2 	= polyop.getFaceCenter randomTerrain (random (3*step) (totalFaces-marginStep))
	
	drawSpline #(pStart, pMid1, pMid2, pEnd) size density
)

randomTerrain = createRandomTerrain size density
randomRoad = createRandomRoad size density
randomTrees = createRandomTrees size treeDensity
randomAnimation = createAnimationCar 350