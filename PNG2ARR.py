
import PIL
import numpy as np
from PIL import Image

#img = Image.open("C:/Users/luengoa/Downloads/windsock.png")
img = Image.open("drone 24.png").rotate(20)
bit = np.asarray(img)
print (bit[:,:,3])



#np.savetxt("BITMAP.txt",rawpb,fmt="%s")


img.show()  # invoke image viewer for debugging
