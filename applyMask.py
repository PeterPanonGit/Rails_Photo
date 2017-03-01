import sys,cv2
import numpy as np

if __name__ == "__main__":
    if len(sys.argv) == 4:
	stylized = sys.argv[1]
        filename = sys.argv[2]
        maskname = sys.argv[3]
	print "foreground: ", filename, "maskname: ", maskname, "background: ", stylized
    else:
        print("Correct Usage: python applyMask.py <filename> <maskname> <stylized>\n")

    img = cv2.imread(filename)
    print "img shape: ", img.shape
    stylized = cv2.imread(stylized)
    print "stylized shape: ", stylized.shape
    mask = cv2.imread(maskname,0)
    mask2 = np.where((mask>0),255,0).astype('uint8')
    print "mask shape: ", mask.shape

    fg = cv2.bitwise_and(img,img,mask=mask2)
    bg = cv2.bitwise_and(stylized,stylized,mask=cv2.bitwise_not(mask2))
    bg_inv = cv2.bitwise_and(stylized,stylized,mask=mask2)
    #output = 0.5*fg + 0.5*bg_inv + bg
    output = fg + bg
    #cv2.imwrite("grabcut_fg.jpg",fg)
    #cv2.imwrite("grabcut_bg.jpg",bg)
    #cv2.imwrite("grabcut_bg_inv.jpg",bg_inv)
    cv2.imwrite("grabcut_output.jpg",output)
    while True:
      cv2.imshow("input",img)
      cv2.imshow("mask",mask)
      cv2.imshow("output",output)
      k = cv2.waitKey(1)
      if k == 27:
	break

