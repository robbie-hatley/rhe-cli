#!/usr/bin/env -S perl -CSDA

########################################################################
#                                                                      #
# "found-poem.pl"                                                      #
#                                                                      #
# Prints a random poem, framed within a Back-Rooms-esque story         #
# in which you find that you've no-clipped out of ordinary reality     #
# and onto a weird desert heath.                                       #
#                                                                      #
########################################################################

use v5.36;
use utf8;

# Subroutine predeclarations:
sub second   ; # "What rough beast slouches towards Bethlehem?"
sub invictus ; # "I am the captain of my soul"
sub highway  ; # "The moon was a ghostly galleon tossed upon cloudy seas"
sub swagman  ; # "You'll never catch me alive!"
sub nazgûl   ; # "Agh burzum-ishi krimpatul"
sub cthulhu  ; # "Ph'nglui mglw'nafh Cthulhu R'lyeh wgah'nagl fhtagn"

# Main body of program:
{
   print ((<<'   END_OF_HEATH') =~ s/^   //gmr);

   You no-clip out of ordinary reality and find yourself standing on what appears
   to be a desert heath at dusk on a cloudy day. Around you, as far as your eye
   can see, are cacti (Saguaro, Prickly Pear, and Cholla) and sand verbena. You
   see no signs of human artifacts or activity. You have the uneasy feeling that
   this place isn't even real.

   Maybe you will eventually be able to no-clip back to normal reality, or maybe
   not. Either way, you may be here a long time, so you might as well enjoy your
   stay. An odd though occurs to you: "I wish I had something to read."

   As you look around this deserted place, a warm dry wind blows a sheet of
   parchment onto your feet. You pick it up. It has a poem written on it.
   It appears to have been written in cursive script with black ink and a
   quill pen. You begin to read.
   END_OF_HEATH
   my $idx = int(time)%6;
   for ($idx) {
      /0/ and second;
      /1/ and invictus;
      /2/ and highway;
      /3/ and swagman;
      /4/ and nazgûl;
      /5/ and cthulhu;
   }
   exit 0;
}

# Subroutine definitions:

sub second {
   print ((<<'   END_OF_SECOND') =~ s/^   //gmr);

   -------------------------------------------------------------------------------

   The Second Coming
   by William Butler Yeats

   Turning and turning in the widening gyre
   The falcon cannot hear the falconer;
   Things fall apart; the centre cannot hold;
   Mere anarchy is loosed upon the world,
   The blood-dimmed tide is loosed, and everywhere
   The ceremony of innocence is drowned;
   The best lack all conviction, while the worst
   Are full of passionate intensity.

   Surely some revelation is at hand;
   Surely the Second Coming is at hand.
   The Second Coming! Hardly are those words out
   When a vast image out of Spiritus Mundi
   Troubles my sight: somewhere in sands of the desert
   A shape with lion body and the head of a man,
   A gaze blank and pitiless as the sun,
   Is moving its slow thighs, while all about it
   Reel shadows of the indignant desert birds.
   The darkness drops again; but now I know
   That twenty centuries of stony sleep
   Were vexed to nightmare by a rocking cradle,
   And what rough beast, its hour come round at last,
   Slouches towards Bethlehem to be born?

   -------------------------------------------------------------------------------

   You drop the poem with a feeling of guilt and despair, and you realize that you
   shouldn't have voted for Donald Trump in the last election.
   END_OF_SECOND
} # end sub second

sub invictus {
   print ((<<'   END_OF_INVICTUS') =~ s/^   //gmr);

   -------------------------------------------------------------------------------

   Invictus
   by William Ernest Henley

   Out of the night that covers me,
      Black as the pit from pole to pole,
   I thank whatever gods may be
      For my unconquerable soul.

   In the fell clutch of circumstance
      I have not winced nor cried aloud.
   Under the bludgeonings of chance
      My head is bloody, but unbowed.

   Beyond this place of wrath and tears
      Looms but the Horror of the shade,
   And yet the menace of the years
      Finds and shall find me unafraid.

   It matters not how strait the gate,
      How charged with punishments the scroll,
   I am the master of my fate,
      I am the captain of my soul.

   -------------------------------------------------------------------------------

   You look around you with new appreciation of the landscape. This place may be
   Hell, but it's YOUR Hell, and you realize you can make of it whatever you want.
   END_OF_INVICTUS
} # end sub invictus

sub highway {
   print ((<<'   END_OF_HIGHWAY') =~ s/^   //gmr);

   -------------------------------------------------------------------------------

   The Highwayman
   By Alfred Noyes

   PART ONE

   The wind was a torrent of darkness among the gusty trees.
   The moon was a ghostly galleon tossed upon cloudy seas.
   The road was a ribbon of moonlight over the purple moor,
   And the highwayman came riding—
            Riding—riding—
   The highwayman came riding, up to the old inn-door.

   He’d a French cocked-hat on his forehead, a bunch of lace at his chin,
   A coat of the claret velvet, and breeches of brown doe-skin.
   They fitted with never a wrinkle. His boots were up to the thigh.
   And he rode with a jewelled twinkle,
            His pistol butts a-twinkle,
   His rapier hilt a-twinkle, under the jewelled sky.

   Over the cobbles he clattered and clashed in the dark inn-yard.
   He tapped with his whip on the shutters, but all was locked and barred.
   He whistled a tune to the window, and who should be waiting there
   But the landlord’s black-eyed daughter,
            Bess, the landlord’s daughter,
   Plaiting a dark red love-knot into her long black hair.

   And dark in the dark old inn-yard a stable-wicket creaked
   Where Tim the ostler listened. His face was white and peaked.
   His eyes were hollows of madness, his hair like mouldy hay,
   But he loved the landlord’s daughter,
            The landlord’s red-lipped daughter.
   Dumb as a dog he listened, and he heard the robber say—

   “One kiss, my bonny sweetheart, I’m after a prize to-night,
   But I shall be back with the yellow gold before the morning light;
   Yet, if they press me sharply, and harry me through the day,
   Then look for me by moonlight,
            Watch for me by moonlight,
   I’ll come to thee by moonlight, though hell should bar the way.”

   He rose upright in the stirrups. He scarce could reach her hand,
   But she loosened her hair in the casement. His face burnt like a brand
   As the black cascade of perfume came tumbling over his breast;
   And he kissed its waves in the moonlight,
            (O, sweet black waves in the moonlight!)
   Then he tugged at his rein in the moonlight, and galloped away to the west.

   PART TWO

   He did not come in the dawning. He did not come at noon;
   And out of the tawny sunset, before the rise of the moon,
   When the road was a gypsy’s ribbon, looping the purple moor,
   A red-coat troop came marching—
            Marching—marching—
   King George’s men came marching, up to the old inn-door.

   They said no word to the landlord. They drank his ale instead.
   But they gagged his daughter, and bound her, to the foot of her narrow bed.
   Two of them knelt at her casement, with muskets at their side!
   There was death at every window;
            And hell at one dark window;
   For Bess could see, through her casement, the road that he would ride.

   They had tied her up to attention, with many a sniggering jest.
   They had bound a musket beside her, with the muzzle beneath her breast!
   “Now, keep good watch!” and they kissed her. She heard the doomed man say—
   Look for me by moonlight;
            Watch for me by moonlight;
   I’ll come to thee by moonlight, though hell should bar the way!

   She twisted her hands behind her; but all the knots held good!
   She writhed her hands till her fingers were wet with sweat or blood!
   They stretched and strained in the darkness, and the hours crawled by like years
   Till, now, on the stroke of midnight,
            Cold, on the stroke of midnight,
   The tip of one finger touched it! The trigger at least was hers!

   The tip of one finger touched it. She strove no more for the rest.
   Up, she stood up to attention, with the muzzle beneath her breast.
   She would not risk their hearing; she would not strive again;
   For the road lay bare in the moonlight;
            Blank and bare in the moonlight;
   And the blood of her veins, in the moonlight, throbbed to her love’s refrain.

   Tlot-tlot; tlot-tlot! Had they heard it? The horsehoofs ringing clear;
   Tlot-tlot; tlot-tlot, in the distance? Were they deaf that they did not hear?
   Down the ribbon of moonlight, over the brow of the hill,
   The highwayman came riding—
            Riding—riding—
   The red coats looked to their priming! She stood up, straight and still.

   Tlot-tlot, in the frosty silence! Tlot-tlot, in the echoing night!
   Nearer he came and nearer. Her face was like a light.
   Her eyes grew wide for a moment; she drew one last deep breath,
   Then her finger moved in the moonlight,
            Her musket shattered the moonlight,
   Shattered her breast in the moonlight and warned him—with her death.

   He turned. He spurred to the west; he did not know who stood
   Bowed, with her head o’er the musket, drenched with her own blood!
   Not till the dawn he heard it, and his face grew grey to hear
   How Bess, the landlord’s daughter,
            The landlord’s black-eyed daughter,
   Had watched for her love in the moonlight, and died in the darkness there.

   Back, he spurred like a madman, shrieking a curse to the sky,
   With the white road smoking behind him and his rapier brandished high.
   Blood red were his spurs in the golden noon; wine-red was his velvet coat;
   When they shot him down on the highway,
            Down like a dog on the highway,
   And he lay in his blood on the highway, with a bunch of lace at his throat.

   And still of a winter’s night, they say, when the wind is in the trees,
   When the moon is a ghostly galleon tossed upon cloudy seas,
   When the road is a ribbon of moonlight over the purple moor,
   A highwayman comes riding—
            Riding—riding—
   A highwayman comes riding, up to the old inn-door.

   Over the cobbles he clatters and clangs in the dark inn-yard.
   He taps with his whip on the shutters, but all is locked and barred.
   He whistles a tune to the window, and who should be waiting there
   But the landlord’s black-eyed daughter,
            Bess, the landlord’s daughter,
   Plaiting a dark red love-knot into her long black hair.

   -------------------------------------------------------------------------------

   As you finish reading this poem, a horse appears from around a bend in a road
   and gallops up to you. On the back of the horse is The Highwayman and his wife,
   Bess. In THIS reality, the Ostler never betrayed The Highwayman, and he and the
   innkeeper's daughter Bess eloped. They prove friendly. They dismount from their
   horse and set-up camp near the side of the road and share food and drink with
   you. After spending some hours story-telling and sharing experiences, the three
   of you grow tired and lie down and sleep. When you awake in the morning, The
   Highwayman and Bess are gone, and so are several valuable items which you had
   in your possession. He couldn't help it, you see; it's his nature.
   END_OF_HIGHWAY
} # end sub highway

sub swagman {
   print ((<<'   END_OF_SWAGMAN') =~ s/^   //gmr);

   -------------------------------------------------------------------------------

   Waltzing Matilda
   By Andrew Barton "Banjo" Paterson, CBE

   Oh there once was a swagman camped in the billabong,
   under the shade of a coolibah tree.
   And he sang as he looked at the old billy boiling:
   "Who'll come a waltzing matilda with me?"

   Who'll come a waltzing matilda my darling
   Who'll come a waltzing matilda with me
   Waltzing matilda and leading a water bag
   Who'll come a waltzing matilda with me

   Down came a jumbuck to drink at the billabong;
   up jumped the swagman and grabbed him with glee.
   And he said as he put him away in the tucker bag
   "You'll come a'waltzing matilda with me!"

   Who'll come a waltzing matilda my darling
   Who'll come a waltzing matilda with me
   Waltzing matilda and leading a water bag
   Who'll come a waltzing matilda with me

   Down came the squatter a'riding his thoroughbred.
   Down came policemen, one, two, and three.
   "Whose is the jumbuck you've got in the tucker bag?
   You'll come a'waltzing matilda with we!"

   Who'll come a waltzing matilda my darling
   Who'll come a waltzing matilda with me
   Waltzing matilda and leading a water bag
   Who'll come a waltzing matilda with me

   But the swagman he up and he jumped in the water-hole
   Drowning himself by the coolibah tree
   And his ghost may be heard as it sings by the billabong:
   "Who'll come a'waltzing matilda with me?"

   Who'll come a waltzing matilda my darling
   Who'll come a waltzing matilda with me
   Waltzing matilda and leading a water bag
   Who'll come a waltzing matilda with me

   -------------------------------------------------------------------------------

   As you finish reading this poem, an Australian swagman walks up and introduces
   himself. You can tell that he's not really alive because he's slightly
   transparent, but that doesn't bother you. You and he gather some desert scrub
   and start a campfire. The swagman finds a stream, gathers water, and makes tea.
   You and he eat roasted jumbuck, drink tea, swap stories, and have a good time.
   END_OF_SWAGMAN
} # end sub swagman

sub nazgûl {
   print ((<<'   END_OF_NAZGÛL') =~ s/^   //gmr);

   -------------------------------------------------------------------------------

   Ash nazg durbatulûk
   Ash nazg gimbatul
   Ash nazg thrakatulûk
   Agh burzum-ishi krimpatul

   -------------------------------------------------------------------------------

   As you finish reading this vile poem, the parchment falls from your hands
   onto the dusty ground. Nine all-black figures ride up on nine black horses
   with glowing red eyes. You are about to have the worst day of your life.
   Unfortunately it will also be the last day of your life has a human.
   You are about to be stabbed with a morgul knife and become a wraith.
   END_OF_NAZGÛL
} # end sub nazgûl

sub cthulhu {
   print ((<<'   END_OF_CTHULHU') =~ s/^   //gmr);

   -------------------------------------------------------------------------------

   Ph'nglui mglw'nafh Cthulhu R'lyeh wgah'nagl fhtagn.

   -------------------------------------------------------------------------------

   As you finish reading this vile poem, the parchment falls from your hands onto
   the ground. The spacetime continuum in front of you shatters and a hideous
   monster erupts from the breech and stands in front of you, gazing into your
   soul with glowing red eyes. You are about to have the worst day of your life.
   Unfortunately it will also be the LAST day of your life as a free, sane human.
   You are about to be enthralled to Cthulhu and become his slave.

   END_OF_CTHULHU
} # end sub cthulhu
