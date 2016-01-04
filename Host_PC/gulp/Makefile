CFLAGS = -O
#CFLAGS = -O -DRHEL3
#CFLAGS = -O -DJUSTCOPY
#CFLAGS = -O -DPCAP32_KLUDGE
#CFLAGS = -O -m32

FILES=license.txt NOTICE gulp.c gulp.1 gulpman.html gulpman.pdf Makefile conv.c gulp.html check64bit.c changelog

gulp:	gulp.c check64bit
	./check64bit; rm -f check64bit
	cc -g $(CFLAGS) gulp.c -o gulp -lpthread -lpcap

gulpman.html:	gulp.1
	nroff -man gulp.1 | bold2html > gulpman.html

gulp.tgz:	$(FILES)
	tar cvfz gulp.tgz $(FILES)

gulpman.pdf:	gulp.1
	groff -man gulp.1 > gulpman.ps && ps2pdf gulpman.ps && rm gulpman.ps
