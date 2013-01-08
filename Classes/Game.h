//
//  Game.h
//  AppScaffold
//

#import <Foundation/Foundation.h>
#import "Sparrow.h"

@interface Game : SPStage
{
    SPSprite *player;
    SPRectangle *boundP;
    
    NSMutableArray *quadsBottom;
    NSMutableArray *quadsTop;
    NSMutableArray *randQuads;
    SPImage *menu;
    SPButton *menuButtonRestart;
    BOOL hasRestart;
    SPButton *menuButtonResume;
    BOOL hasResume;
    SPButton *pauseButton;
    
    int quadWidth;
    int numQuads;
    int checkQuadIndexStart;
    int checkQuadIndexEnd;
    
    double quadScrlSpd;
    double bottomQuadPos;
    double distBWQuads;
    double chBottomQuadPos;
    BOOL increaseUp;
    
    
    int score;
    int highScore;
    SPTextField *scoreText;
    SPTextField *scoreTextMenu;
    SPTextField *highScoreText;
    BOOL hasScore;
    BOOL hasHighScore;
    
    double velocity;
    double acceleration;
    
    BOOL touchedScreen; 
    BOOL GameOver;
    
    SPQuad *quad;
    SPImage *image1;
    
}


-(double)getNextX;
-(void)initBack;
-(void)initQuads;
-(void)gameOver;
-(void)pressedStart:(SPEvent *)event;
-(void)pressedPause:(SPEvent *)event;
-(void)pressedRestart:(SPEvent *)event;
-(void)pressedResume:(SPEvent *)event;
-(void)moveQuads:(SPEvent *)event;

-(void)movePlayer:(SPEvent *)event;
-(void)hasTouched:(SPTouchEvent *)event;

@end
