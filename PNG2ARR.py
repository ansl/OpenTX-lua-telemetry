
import PIL
import numpy as np
from PIL import Image

#img = Image.open("C:/Users/luengoa/Downloads/windsock.png")
img = Image.open("navegante.png").rotate(0)
bit = np.asarray(img)
print (bit[:,:,0])



np.savetxt("BITMAP_R.txt",(bit[:,:,0]),fmt="%i",delimiter=',')
np.savetxt("BITMAP_G.txt",(bit[:,:,1]),fmt="%i",delimiter=',')
np.savetxt("BITMAP_B.txt",(bit[:,:,2]),fmt="%i",delimiter=',')
np.savetxt("BITMAP_A.txt",(bit[:,:,3]),fmt="%i",delimiter=',')

img.show()  # invoke image viewer for debugging
