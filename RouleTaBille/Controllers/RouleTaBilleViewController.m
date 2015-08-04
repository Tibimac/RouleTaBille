//
//  RouleTaBilleViewController.m
//  RouleTaBille
//
//  Created by Thibault Le Cornec on 27/06/2014.
//  Copyright (c) 2014 Tibimac. All rights reserved.
//

#import "RouleTaBilleViewController.h"

@interface RouleTaBilleViewController ()
{
    RouleTaBilleView *mainView;
    BOOL onBorderX;
    BOOL canPlaySoundOnX;
    BOOL onBorderY;
    BOOL canPlaySoundOnY;
    NSInteger radius;
}
@end

@implementation RouleTaBilleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //  Init de la vue
    mainView = [[RouleTaBilleView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [[self view] addSubview:mainView];
    [mainView release];
    
    
    //  Récupération des URL des images du dossier Backgrounds
    NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];
    NSURL *imagesURL = [NSURL URLWithString:@"Backgrounds" relativeToURL:bundleURL];
    
    // Liste le contenu du répertoire des images à l'URL imagesURL et récupère le chemin de chaque fichier
    // NSDirectoryEnumerationSkipsHiddenFiles permet de ne pas lister les fichiers invisibles
    backgroundImagesURL = [[NSArray alloc] initWithArray:[[NSFileManager defaultManager]
                                                            contentsOfDirectoryAtURL:imagesURL
                                                            includingPropertiesForKeys:nil
                                                            options:NSDirectoryEnumerationSkipsHiddenFiles
                                                            error:nil]];
    
    //  Récupération et Affectation de l'image par défaut
    NSURL *fileURL = [backgroundImagesURL objectAtIndex:0];
    UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:fileURL]];
    [[mainView backgroundView] setImage:image];
    [image release];
    image = nil;
    
    //  Incréement du compteur pour connait l'index de la prochain image à afficher
    indexImageToShow = 1;
    
    //  Pour recevoir les events UIResponder (gestion du shake)
    [self becomeFirstResponder];
    
    
    //  Initialisation du CoreMotionManager er du Timer
    coreMotionManager = [[CMMotionManager alloc] init];
    NSTimeInterval motionUpdatesInterval = 0.001;
    [coreMotionManager setAccelerometerUpdateInterval:motionUpdatesInterval];
    [coreMotionManager startAccelerometerUpdates];
    
    _theTimer = [[NSTimer scheduledTimerWithTimeInterval:motionUpdatesInterval
                                               target:self
                                             selector:@selector(updateBallPosition:)
                                             userInfo:nil
                                              repeats:YES] retain];
    
    //  Charge le son mais ne le jour pas
    [self loadSound:YES andPlay:NO];
    
    // La balle part du centre donc dés qu'elle touchera un bord on pourras jouer le son
    canPlaySoundOnX = YES;
    canPlaySoundOnY = YES;
    //  Rayon de la bille.
    radius = 25;
}


- (BOOL)canBecomeFirstResponder
{
    return YES;
}


//  Méthode appellée lorsqu'un shake se termine
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        //  Récupération de l'image suivante dans le tableau
        // Récupération URL de l'image
        NSURL *imageFileURL = [backgroundImagesURL objectAtIndex:(indexImageToShow)];
        // Chargement de l'image à l'URL indiquée
        UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:imageFileURL]];
        // Affectation de l'image à la vue
        [[mainView backgroundView] setImage:image];

        //  Incrément de l'index pour la prochaine image à afficher
        indexImageToShow++;
        
        //  Si l'image affichée est la 3, suite à l'incrément l'index dépasse le tableau
        //      donc on le remet à 0
        if (indexImageToShow == [backgroundImagesURL count])
        {
            indexImageToShow = 0;
        }
        [image release];
        image = nil;
    }
}


//  Méthode appellée pour charger et/ou jouer le son
- (void)loadSound:(BOOL)load andPlay:(BOOL)play
{
    if (load) // Si besoin de réinitialiser le player
    {
        //  Le player ne peut servir qu'une fois
        if (soundPlayer == nil)
        {
            //  Récupération du fichier du son
            NSError *err;
            NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"poc" ofType:@"wav"];
            NSURL *soundFileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath];

            soundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:&err];
            [soundFileURL release];
            
            if(soundPlayer) // Si l'instanciation a réussie
            {
                // Reparamétrage du player
                [soundPlayer setDelegate:self];
                [soundPlayer prepareToPlay];
            }
            else
            {
                NSLog(@"Erreur création player.");
            }
        }
    }
    
    if (play) // Si on a demandé à jouer le son
    {
        [soundPlayer play];
    }
}


- (void)updateBallPosition:(NSTimer *)timer
{
    CGPoint newCenterPosition;
    
    newCenterPosition.x = [mainView ball].center.x + ([[coreMotionManager accelerometerData]acceleration].x*3);
    newCenterPosition.y = [mainView ball].center.y - ([[coreMotionManager accelerometerData]acceleration].y*3);

    
    ////////// DETECTION DES BORDS //////////
    
    //  Détection bord gauche
    if (newCenterPosition.x <= radius) // Si le center est inférieur à 25 = trop à gauche
    {
        newCenterPosition.x = radius; // On replace le centre de la ball à 25
    }

    //  Détection bord droit
    if (newCenterPosition.x >= [mainView frame].size.width-radius)
    {
        newCenterPosition.x = [mainView frame].size.width-radius;
    }

    //  Détection bord haut
    if (newCenterPosition.y <= radius)
    {
        newCenterPosition.y = radius;
    }

    //  Détection bord bas
    if (newCenterPosition.y >= [mainView frame].size.height-radius)
    {
        newCenterPosition.y = [mainView frame].size.height-radius;
    }

    ////////// REPOSITIONNEMENT DE LA BILLE //////////
    [mainView ball].center = CGPointMake(newCenterPosition.x, newCenterPosition.y);
    
    
    ////////// GESTION SON //////////
    // Gestion pour savoir si on est sur un bord ou non et si on peux jouer le son
    // X
    //  Bord gauche                           ou         Bord droit
    if (([mainView ball].center.x < radius+1) || ([mainView ball].center.x > [mainView frame].size.width-(radius+1)))
    {
        onBorderX = YES;
    }
    else
    {
        onBorderX = NO;
        canPlaySoundOnX = YES;
    }
    
    // Y
    //  Bord haut                             ou         Bord bas
    if (([mainView ball].center.y < radius+1) || ([mainView ball].center.y > [mainView frame].size.height-(radius+1)))
    {
        onBorderY = YES;
    }
    else
    {
        onBorderY = NO;
        canPlaySoundOnY = YES;
    }

    
    ////////// PLAY SON //////////
    // Gestion du son
    if (onBorderX && canPlaySoundOnX)
    {
        [self loadSound:NO andPlay:YES];
        canPlaySoundOnX = NO;
    }
    
    if (onBorderY && canPlaySoundOnY)
    {
        [self loadSound:NO andPlay:YES];
        canPlaySoundOnY = NO;
    }
        
}


-(BOOL)shouldAutorotate
{
    return NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
