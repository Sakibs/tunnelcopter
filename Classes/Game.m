//
//  Game.m
//  AppScaffold
//

#import "Game.h" 

@implementation Game

- (id)initWithWidth:(float)width height:(float)height
{
    if ((self = [super initWithWidth:width height:height]))
    {        
        srandom(time(0));
        
        
        velocity = 0;
        touchedScreen = FALSE;
        GameOver = FALSE;
        numQuads = 100;
        quadWidth = 5;
        checkQuadIndexStart = 0;
        checkQuadIndexEnd = 10;
        bottomQuadPos = 20;
        chBottomQuadPos = 20;
        distBWQuads = 280;
        quadScrlSpd = 3.5;
        score = 0;
        highScore = 0;
        
        if(rand()%10 < 5)
            increaseUp = TRUE;
        else
            increaseUp = FALSE;
        
        
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
        NSString *documentsDirectory = [paths objectAtIndex:0]; //2
        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"score.plist"]; //3
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if (![fileManager fileExistsAtPath: path]) //4
        {
            NSString *bundle = [[NSBundle mainBundle] pathForResource:@"score" ofType:@"plist"]; //5
            
            [fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
        }
        
        NSMutableDictionary *savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
        
        //load from savedStock example int value
        int value;
        value = [[savedStock objectForKey:@"highscore"] intValue];
        
        [savedStock release];
        
        if(value > highScore)
        {
            highScore = value;
        }
        
        [self initBack];
        
        quadsBottom = [[NSMutableArray alloc] init];
        quadsTop = [[NSMutableArray alloc] init];
        randQuads = [[NSMutableArray alloc] init];
        [self initQuads];
        
        
        
        menu = [SPImage imageWithContentsOfFile:@"startMenuScreen.png"];
        menu.rotation = SP_D2R(90);
        menu.x = menu.width;
        [self addChild:menu];
        [self addEventListener:@selector(pressedStart:) atObject:self forType:(SP_EVENT_TYPE_TOUCH)];
        
        
        highScoreText = [SPTextField textFieldWithWidth:200 height:50 text:[NSString stringWithFormat:@"High Score: %i", highScore]];
        highScoreText.rotation = SP_D2R(90);
        highScoreText.fontSize = 20;
        highScoreText.y = 140;
        highScoreText.x = 140;
        [self addChild: highScoreText];

        }
    return self;
}

-(void)pressedStart:(SPEvent *)event
{
    [self removeEventListener:@selector(pressedStart:) atObject:self forType:(SP_EVENT_TYPE_TOUCH)];
    [self removeChild:menu];
    [self removeChild:highScoreText];
    
    image1 = [SPImage imageWithContentsOfFile:@"heliPlayer.png"];
    
    player = [SPSprite sprite];
    [player addChild:image1];
    player.rotation = SP_D2R(90);
    player.x = 320/2 - player.height/2; 
    player.y = 15;
    [self addChild:player];
    
    
    scoreText = [SPTextField textFieldWithWidth:200 height:30 text:[NSString stringWithFormat:@"Score: %i", score]];
    scoreText.x = 320;
    scoreText.y = 150;
    scoreText.fontSize = 20;
    scoreText.rotation = SP_D2R(90);
    scoreText.border = TRUE;
    scoreText.color = 0xffffff;
    [self addChild:scoreText];
    [scoreText setText:[NSString stringWithFormat:@"Score: %i", score]];
    
    
    SPTexture *pause = [SPTexture textureWithContentsOfFile:@"pauseButton.png"];
    pauseButton = [SPButton buttonWithUpState:pause];
    pauseButton.rotation = SP_D2R(90);
    pauseButton.x = pauseButton.width;
    [self addChild:pauseButton];
    
    
    [self addEventListener:@selector(hasTouched:) atObject:self forType:(SP_EVENT_TYPE_TOUCH)];
    [self addEventListener:@selector(movePlayer:) atObject:self forType:(SP_EVENT_TYPE_ENTER_FRAME)];
    [self addEventListener:@selector(moveQuads:) atObject:self forType:(SP_EVENT_TYPE_ENTER_FRAME)];
    [pauseButton addEventListener:@selector(pressedPause:) atObject:self forType:(SP_EVENT_TYPE_TRIGGERED)];

}

-(void)gameOver
{
    GameOver = TRUE;
    [self removeEventListener:@selector(hasTouched:) atObject:self forType:(SP_EVENT_TYPE_TOUCH)];
    [self removeEventListener:@selector(movePlayer:) atObject:self forType:(SP_EVENT_TYPE_ENTER_FRAME)];
    [self removeEventListener:@selector(moveQuads:) atObject:self forType:(SP_EVENT_TYPE_ENTER_FRAME)];
    [pauseButton removeEventListener:@selector(pressedPause:) atObject:self forType:(SP_EVENT_TYPE_TRIGGERED)];
        
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"score.plist"]; //3
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path]) //4
    {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"score" ofType:@"plist"]; //5
        
        [fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
    }
    
    
    
    NSMutableDictionary *savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    
    //load from savedStock example int value
    int value;
    value = [[savedStock objectForKey:@"highscore"] intValue];
    
    [savedStock release];
    
    
    BOOL newHigh = FALSE;
    if(score > value)
    {
        NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        
        //here add elements to data file and write data to file
        
        [data setObject:[NSNumber numberWithInt:(score+1)] forKey:@"highscore"];
        
        [data writeToFile:path atomically:YES];
        [data release];
        highScore = score+1;
        newHigh = TRUE;
    }
    
    
    SPTexture *buttonImage = [SPTexture textureWithContentsOfFile:@"restartButton.png"];
    menu = [SPImage imageWithContentsOfFile:@"gameOverScreen.png"];
    menu.rotation = SP_D2R(90);
    menu.x = menu.width;
    menuButtonRestart = [SPButton buttonWithUpState:buttonImage];
    menuButtonRestart.rotation = SP_D2R(90);
    menuButtonRestart.x = 100;
    menuButtonRestart.y = 240-menuButtonRestart.width/2;
    
    int displayScore = score+1;
    scoreTextMenu = [SPTextField textFieldWithWidth:200 height:30 text:[NSString stringWithFormat:@"Score: %i", displayScore]];
    scoreTextMenu.rotation = SP_D2R(90);
    scoreTextMenu.y = 240 - scoreText.height/2;
    scoreTextMenu.x = 160;
    scoreTextMenu.fontSize = 20;
    
    if(newHigh)
        highScoreText = [SPTextField textFieldWithWidth:200 height:30 text:[NSString stringWithFormat:@"New High Score!!!"]];
    else
        highScoreText = [SPTextField textFieldWithWidth:200 height:30 text:[NSString stringWithFormat:@"High Score: %i", highScore]];
    highScoreText.rotation = SP_D2R(90);
    highScoreText.y = 240 - highScoreText.height/2;
    highScoreText.x = 130;
    highScoreText.fontSize = 20;

    
    [self addChild:menu];
    [self addChild:menuButtonRestart];
    [menuButtonRestart addEventListener:@selector(pressedRestart:) atObject:self forType:(SP_EVENT_TYPE_TRIGGERED)];
    hasResume = FALSE;
    hasRestart = TRUE;
    [self addChild:scoreTextMenu];
    [self addChild:highScoreText];
    hasHighScore = TRUE;
    hasScore = TRUE;
}

-(void)pressedPause:(SPEvent *)event
{
    [self removeEventListener:@selector(hasTouched:) atObject:self forType:(SP_EVENT_TYPE_TOUCH)];
    [self removeEventListener:@selector(movePlayer:) atObject:self forType:(SP_EVENT_TYPE_ENTER_FRAME)];
    [self removeEventListener:@selector(moveQuads:) atObject:self forType:(SP_EVENT_TYPE_ENTER_FRAME)];
    [pauseButton removeEventListener:@selector(pressedPause:) atObject:self forType:(SP_EVENT_TYPE_TRIGGERED)];
    menu = [SPImage imageWithContentsOfFile:@"pauseScreen.png"];
    menu.rotation = SP_D2R(90);
    menu.x = menu.width;

    SPTexture *buttonImage = [SPTexture textureWithContentsOfFile:@"resumeButton.png"];
    menuButtonResume = [SPButton buttonWithUpState:buttonImage];
    menuButtonResume.rotation = SP_D2R(90);
    menuButtonResume.scaleX=.9;
    menuButtonResume.scaleY=.9;
    menuButtonResume.x = 120;
    menuButtonResume.y = 250-menuButtonResume.width+7;
    
    buttonImage = [SPTexture textureWithContentsOfFile:@"restartButton.png"];
    menuButtonRestart = [SPButton buttonWithUpState:buttonImage];
    menuButtonRestart.rotation = SP_D2R(90);
    menuButtonRestart.scaleX=.9;
    menuButtonRestart.scaleY=.9;
    menuButtonRestart.x = 120;
    menuButtonRestart.y = 240;
    
    highScoreText = [SPTextField textFieldWithWidth:200 height:30 text:[NSString stringWithFormat:@"High Score: %i", highScore]];
    highScoreText.rotation = SP_D2R(90);
    highScoreText.y = 240 - highScoreText.height/2+7;
    highScoreText.x = 155;
    highScoreText.fontSize = 20;
    
    
    [self addChild:menu];
    [self addChild:menuButtonResume];
    [menuButtonResume addEventListener:@selector(pressedResume:) atObject:self forType:(SP_EVENT_TYPE_TRIGGERED)];
    hasResume = TRUE;
    [self addChild:menuButtonRestart];
    [menuButtonRestart addEventListener:@selector(pressedRestart:) atObject:self forType:(SP_EVENT_TYPE_TRIGGERED)];
    hasRestart = TRUE;
    hasScore = FALSE;
    [self addChild:highScoreText];
    hasHighScore = TRUE;
}

-(void)pressedResume:(SPEvent *)event
{
    [self removeChild:menuButtonRestart];
    [self removeChild:menuButtonResume];
    [self removeChild:menu];
    [self removeChild:highScoreText];
    
    touchedScreen = FALSE;
    
    [self addEventListener:@selector(hasTouched:) atObject:self forType:(SP_EVENT_TYPE_TOUCH)];
    [self addEventListener:@selector(movePlayer:) atObject:self forType:(SP_EVENT_TYPE_ENTER_FRAME)];
    [self addEventListener:@selector(moveQuads:) atObject:self forType:(SP_EVENT_TYPE_ENTER_FRAME)];
    [pauseButton addEventListener:@selector(pressedPause:) atObject:self forType:(SP_EVENT_TYPE_TRIGGERED)];
     
}

-(void)pressedRestart:(SPEvent *)event
{
    if(hasScore)
    {
        [self removeChild:scoreTextMenu];
    }
    if(hasHighScore)
    {
        [self removeChild:highScoreText];
    }
    if(hasRestart)
    {
        [self removeChild:menuButtonRestart];
    }
    if(hasResume)
    {
        [self removeChild:menuButtonResume];
    }
    [self removeChild:menu];
    
    SPImage *restartMessage = [SPImage imageWithContentsOfFile:@"restartMessage.png"];
    restartMessage.rotation = SP_D2R(90);
    restartMessage.x=restartMessage.width;
    [self addChild:restartMessage];
    
    [scoreText setText:[NSString stringWithFormat:@"Score: %i", score]];
    
    player.x = 320/2 - player.height/2;
    bottomQuadPos = 20;
    distBWQuads = 280;
    velocity = 0;
    touchedScreen = FALSE;
    GameOver = FALSE;
    checkQuadIndexStart = 0;
    checkQuadIndexEnd = 10;
    bottomQuadPos = 20;
    chBottomQuadPos = 20;
    distBWQuads = 280;
    quadScrlSpd = 3.5;
    score = 0;

    
    int ypos = 0;
    int blockpos = 490;
    
    
    for (int i=0; i<numQuads; i++)
    {
        uint randomColor = arc4random() % 16777215;
        SPQuad *myQuad = [quadsBottom objectAtIndex:i];
        myQuad.x = bottomQuadPos;
        myQuad.y = ypos;
        myQuad.color = randomColor;
        
        SPQuad *myQuad1 = [quadsTop objectAtIndex:i];
        myQuad1.x = bottomQuadPos+distBWQuads;
        myQuad1.y = ypos;
        myQuad1.color = randomColor;
        
        ypos+=quadWidth;
    }
    
    
    for (int i = 0; i<2; i++) {
        SPQuad *block = [randQuads objectAtIndex:i];
        block.y = blockpos;
        int dist = (distBWQuads);
        int randX = rand()%dist;
        block.x = randX + bottomQuadPos;
        
        blockpos+= 250;
    }
    
    [self removeChild:restartMessage];
    [self addEventListener:@selector(hasTouched:) atObject:self forType:(SP_EVENT_TYPE_TOUCH)];
    [self addEventListener:@selector(movePlayer:) atObject:self forType:(SP_EVENT_TYPE_ENTER_FRAME)];
    [self addEventListener:@selector(moveQuads:) atObject:self forType:(SP_EVENT_TYPE_ENTER_FRAME)];
    [pauseButton addEventListener:@selector(pressedPause:) atObject:self forType:(SP_EVENT_TYPE_TRIGGERED)];

}


-(double)getNextX
{
    if (distBWQuads > 150) {
        bottomQuadPos+=.02;
        distBWQuads-=.04;
        chBottomQuadPos+=.02;
        quadScrlSpd+=.005;
    }
    else
    {
        if (quadScrlSpd <= 20) {
            quadScrlSpd+=.01;
        }
        
    }
    
    if(distBWQuads > 180)
    {
        int willChangeToRandPos = rand()%100;
        
        if (willChangeToRandPos <= 1) {
            int doubleBottomPos = 2*bottomQuadPos;
            chBottomQuadPos = rand()%doubleBottomPos;
            
            int changeDirVar = rand()%100;
            if(changeDirVar <= 49)
            {
                if (increaseUp) {
                    increaseUp = FALSE;
                }
                else 
                {
                    increaseUp = TRUE;
                }
            }
        }
        else
        {
            int changeDirVar = rand()%100;
            
            if(changeDirVar <= 9)
            {
                if (increaseUp) {
                    increaseUp = FALSE;
                }
                else
                {
                    increaseUp = TRUE;
                }
            }
            
            
            if(chBottomQuadPos+2 > 2*bottomQuadPos)
            {
                increaseUp = FALSE;
            }
            else if(chBottomQuadPos-2 < 0)
            {
                increaseUp = TRUE;
            }
            
            if (increaseUp) {
                chBottomQuadPos = chBottomQuadPos + rand()%5;
            }
            else
                chBottomQuadPos = chBottomQuadPos - rand()%5;
            
        }
    }
    else
    {
        int changeDirVar = rand()%100;
        
        if(changeDirVar <= 9)
        {
            if (increaseUp) {
                increaseUp = FALSE;
            }
            else
            {
                increaseUp = TRUE;
            }
        }
        
        
        if(chBottomQuadPos+2 > 2*bottomQuadPos)
        {
            increaseUp = FALSE;
        }
        else if(chBottomQuadPos-2 < 0)
        {
            increaseUp = TRUE;
        }
        
        if (increaseUp) {
            chBottomQuadPos = chBottomQuadPos + rand()%5;
        }
        else
            chBottomQuadPos = chBottomQuadPos - rand()%5;

    }
    
    return chBottomQuadPos;
}

-(void)initBack
{
    int ran = rand()%100;
    
    
    if(ran >= 0 && ran <=50)
    {
        uint bottomColor = arc4random() % 16777215;
        uint topColor = arc4random() % 16777215;
        
        
        SPQuad *gradient = [SPQuad quadWithWidth:320 height:480];
        [gradient setColor:topColor       ofVertex:0];
        [gradient setColor:bottomColor    ofVertex:1];
        [gradient setColor:topColor       ofVertex:2];
        [gradient setColor:bottomColor    ofVertex:3];
        [self addChild:gradient];        
    }
    else
    {
        uint corner1 = arc4random() % 16777215;
        uint corner2 = arc4random() % 16777215;
        uint corner3 = arc4random() % 16777215;
        uint corner4 = arc4random() % 16777215;
        
        SPQuad *gradient = [SPQuad quadWithWidth:320 height:480];
        [gradient setColor:corner1    ofVertex:0];
        [gradient setColor:corner2    ofVertex:1];
        [gradient setColor:corner3    ofVertex:2];
        [gradient setColor:corner4    ofVertex:3];
        [self addChild:gradient];        
    }
}

-(void)initQuads
{
    int ypos = 0;
    int blockpos = 490;
    
        
    for (int i=0; i<numQuads; i++)
    {
        uint randomColor = arc4random() % 16777215;
        SPQuad *myQuad = [SPQuad quadWithWidth:200 height:quadWidth];
        myQuad.pivotX = myQuad.width;
        myQuad.x = bottomQuadPos;
        myQuad.y = ypos;
        myQuad.color = randomColor;
        [quadsBottom addObject:myQuad];
        
        SPQuad *myQuad1 = [SPQuad quadWithWidth:200 height:quadWidth];
        myQuad1.x = bottomQuadPos+distBWQuads;
        myQuad1.y = ypos;
        myQuad1.color = randomColor;
        [quadsTop addObject:myQuad1];
        
        ypos+=quadWidth;
    }
    
    for (int i=0; i<numQuads; i++) {
        SPQuad *temp = [quadsTop objectAtIndex:i];
        [self addChild:temp];
        temp = [quadsBottom objectAtIndex:i];
        [self addChild:temp];
    }
    
    for (int i = 0; i<2; i++) {
        uint randomColor = arc4random() % 16777215;
        SPQuad *block = [SPQuad quadWithWidth:70 height:20];
        block.pivotX = block.width;
        block.y = blockpos;
        int dist = (distBWQuads);
        int randX = rand()%dist;
        //block.x = randX + bottomQuadPos;
        block.x = randX + 70;
        block.color = randomColor;
        [self addChild:block];
        [randQuads addObject:block];
        
        blockpos+= 250;
    }


}

-(void)moveQuads:(SPEvent *)event
{
    score++;
    [scoreText setText:[NSString stringWithFormat:@"Score: %i", score]];
        
    
    for (int i=0; i<2; i++) {
        SPQuad *tempBlock = [randQuads objectAtIndex:i];
        
        if(tempBlock.y <= -tempBlock.height)
        {
            tempBlock.y = 490;
            int dist = (distBWQuads);
            int randX = rand()%dist;
            //tempBlock.x = randX + bottomQuadPos;
            tempBlock.x = randX + 70;

        }
        if(distBWQuads <= 180 && tempBlock.y == 490)
        {
            continue;
        }
        else tempBlock.y = tempBlock.y - quadScrlSpd;
    }
    
    for (int i=0; i<numQuads; i++) {
        SPQuad *temp = [quadsBottom objectAtIndex:i];
        SPQuad *temp1 = [quadsTop objectAtIndex:i];
        if(temp.y <= -temp.height)
        {
            uint randomColor = arc4random() % 16777215;
            temp.color = randomColor;
            temp1.color = randomColor;
            
            temp.y = temp.y + numQuads*quadWidth;
            temp.x = [self getNextX];
            
            temp1.y = temp1.y + numQuads*quadWidth;
            temp1.x = temp.x + distBWQuads;
            
            if(checkQuadIndexEnd+1 == numQuads)
            {
                checkQuadIndexEnd = 0;
            }
            else checkQuadIndexEnd++;
            
            if(checkQuadIndexStart+1 == numQuads)
            {
                checkQuadIndexStart = 0;
            }
            else checkQuadIndexStart++;
        }
        temp.y = temp.y - quadScrlSpd;
        temp1.y = temp1.y - quadScrlSpd;
    }
    
}

-(void)movePlayer:(SPEvent *)event
{
    if(touchedScreen)
    {
        player.rotation = SP_D2R(85);
    }
    else 
        player.rotation= SP_D2R(90);
    
    boundP = player.bounds;
    int i = checkQuadIndexStart;
    
    for(int i=0; i<2; i++)
    {
        if(GameOver == TRUE)
            break;
        
        SPQuad *tempBlock = [randQuads objectAtIndex:i];
        SPRectangle *boundQ = tempBlock.bounds;
        if([boundP intersectsRectangle:boundQ])
        {
            //velocity = 0;
            //player.x = 320/2 - player.height/2;
            [self gameOver];
        }
    }
    
    while(i!=checkQuadIndexEnd) {
        if(GameOver == TRUE)
            break;
        SPQuad *temp = [quadsBottom objectAtIndex:i];
        SPQuad *temp1 = [quadsTop objectAtIndex:i];
        SPRectangle *boundB = temp.bounds;
        SPRectangle *boundT = temp1.bounds;
        if([boundP intersectsRectangle:boundB] || [boundP intersectsRectangle:boundT])
        {
            [self gameOver];
        }
        if(i+1 == numQuads)
            i = 0;
        else i++;
    }
    
    if(!GameOver)
    {
    if(touchedScreen == TRUE)
    {
        velocity+=.4;
        player.x = player.x + velocity;
    }
    
    else
    {
        velocity-=.4;
        player.x = player.x + velocity;
    }
    }
}

-(void) hasTouched:(SPTouchEvent *)event
{
    SPTouch *touch = [[event touchesWithTarget:self andPhase:SPTouchPhaseBegan] anyObject];
    if(touch)
    {
        touchedScreen = TRUE;
    }
    touch = [[event touchesWithTarget:self andPhase:SPTouchPhaseEnded] anyObject];
    if(touch)
    {
        touchedScreen = FALSE;
    }
}


@end
