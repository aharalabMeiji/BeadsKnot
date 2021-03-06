class Square{
	data_extract de;
	int e[][];// 切り取られた画像の2値化データ
	int s;
	int w,h;

	Square(data_extract _de){
		de = _de;
		w = de.w;
		h = de.h;
		s = 10;
	}

	boolean getSquareExtraction(){
		s = de.thickness();//d[][]から線の太さを見積もる


		boolean ofutarisama_flag;
		int loopLimit = 1;//min(10,s);
		int kaisa = 0;	
		do { 
			if (kaisa % 2 == 0) {
				s -= kaisa;
			} else {
				s += kaisa;
			}
			kaisa++;

			de.extraction_beads = false;
			de.nbhs.clear();
			de.points.clear();

			for (int y=0; y<de.h; y+=s) {
				for (int x=0; x<de.w; x+=s) {
					copy_area(x, y);
				}
			}

			//cancelLoop();がいるらしい。
			de.countNbhs();
			de.removeThrone();
			de.countNbhs();
			de.fillGap();
			de.countNbhs();
			de.FindJoint();

			de.getDisplayLTRB();
			de.extraction_beads = true;

			ofutarisama_flag=de.Ofutarisama();
			println(ofutarisama_flag, s);
			de.tf.ln=s;
			if(ofutarisama_flag) break;
		} while (kaisa < loopLimit);

		if (ofutarisama_flag) {
			de.extraction_complete = true;
			println("extraction is finished. points # ="+de.points.size()+", Nbh # ="+de.nbhs.size());
			// Joint用のNbhの設置
			de.addJointToNbhs();
			// dispのデータを書き換える。
			de.getDisplayLTRB();
			// バネモデルの初期化
			de.tf.spring_setup();
			return true;
		} else {
			println("extraction failed.");
			return false;
		}
	}

  	void copy_area(int x, int y) {//
  		e = new int[s][s];
  		if (x<0 || x+s>w || y<0 || y+s>h) {
  			return;
  		}
  		for (int j=0; j<s; j++) {
  			for (int i=0; i<s; i++) {
  				e[i][j]=de.d[x+i][y+j];
  			}
  		}
  		float XY=0, X=0, Y=0, XX=0, YY=0;
  		int num=0;
  		for (int j=0; j<s; j++) {
  			for (int i=0; i<s; i++) {
  				if ( e[i][j]==1) {
  					XY+=i*j;
  					X+=i;
  					Y+=j;
  					XX+=i*i;
  					YY+=j*j;
  					num++;
  				}
  			}
  		}
  		int v1=0;
  		int v2=0;
  		int v3=0;
  		int v4=0;

    	if (num>(s*s)/10) {//1割以上だったら
    		if ((num*XX)-(X*X)>(num*YY)-(Y*Y)) {
    			float a=(num*XY-X*Y)/((num*XX)-(X*X));
    			float b=(XX*Y-XY*X)/((num*XX)-(X*X));
        		boolean p1=(b>=0&&b<=s&&de.d[x][(int)(y+b)]==1);//p1が辺上に乗っているならば
        		float k=a*s+b;
        		boolean p2=(k>=0&&k<=s&&de.d[x+s][(int)(y+k)]==1); //p2が辺上に載っているならば
        		float h=-b/a;
		        //if(a==0)何か処理が必要
		        boolean p3=(h>=0&&h<=s&&de.d[(int)(x+h)][y]==1); //p3が辺上に載っているならば
		        float l=(s-b)/a;
		        boolean p4=(l>=0&&l<=s&&de.d[(int)(x+l)][y+s]==1); //p4が辺上に載っているならば
		        if (p1) {
		        	v1=de.addToPoints(x, (int)(y+b),s);
		        }
		        if (p2) {
		        	v2=de.addToPoints(x+s, (int)(y+k),s);
		        }
		        if (p3) {
		        	v3=de.addToPoints((int)(x+h), y,s);
		        }
		        if (p4) {
		        	v4=de.addToPoints((int)(x+l), y+s,s);
		        }
		        if (p1&&p2) {
		        	de.addToNbhs(v1, v2);
		        }
		        if (p2&&p3) {
		        	de.addToNbhs(v2, v3);
		        }
		        if (p1&&p4) {
		        	de.addToNbhs(v1, v4);
		        }
		        if (p1&&p3) {
		        	de.addToNbhs(v1, v3);
		        }
		        if (p2&&p4) {
		        	de.addToNbhs(v2, v4);
		        }
		    } else {
		    	float a=(num*XY-X*Y)/((num*YY)-(Y*Y));
		    	float b=(YY*X-XY*Y)/((num*YY)-(Y*Y));
		        boolean p1=(b>=0&&b<=s&&de.d[(int)(x+b)][y]==1);//p1が辺上に乗っているならば
		        float k=a*s+b;
		        boolean p2=(k>=0&&k<=s&&de.d[(int)(x+k)][y+s]==1); //p2が辺上に載っているならば
		        float h=-b/a;
		        //if(a==0)何か処理が必要
		        boolean p3=(h>=0&&h<=s&&de.d[x][(int)(y+h)]==1); //p3が辺上に載っているならば
		        float l=(s-b)/a;
		        boolean p4=(l>=0&&l<=s&&de.d[x+s][(int)(y+l)]==1); //p4が辺上に載っているならば
		        if (p1) {
		        	v1=de.addToPoints((int)(x+b), y,s);
		        }
		        if (p2) {
		        	v2=de.addToPoints((int)(x+k), y+s,s);
		        }
		        if (p3) {
		        	v3=de.addToPoints(x, (int)( y+h),s);
		        }
		        if (p4) {
		        	v4=de.addToPoints(x+s, (int)(y+l),s);
		        }
		        if (p1&&p2) {
		        	de.addToNbhs(v1, v2);
		        }
		        if (p2&&p3) {
		        	de.addToNbhs(v2, v3);
		        }
		        if (p1&&p4) {
		        	de.addToNbhs(v1, v4);
		        }
		        if (p1&&p3) {
		        	de.addToNbhs(v1, v3);
		        }
		        if (p2&&p4) {
		        	de.addToNbhs(v2, v4);
		        }
		    }

		    boolean OKy=true;
		    int flagy;
		    int i1=0;
		    int i2=s-1;
		    int i3=0;
		    int i4=0;
		    for (int j=0; j<s; j++) {
		    	flagy=0;
		    	for (int i=0; i<s; i++) {
		    		if (flagy==0&&e[i][j]==0) {
		    			flagy=1;
		    		} else if (flagy==0&&e[i][j]==1) {
		    			flagy=2;
		    			i1=i;
		    		} else if (flagy==1&&e[i][j]==1) {
		    			flagy=2;
		    			i1=i;
		    		} else if (flagy==2&&e[i][j]==0) {
		    			flagy=3;
		    			i2=i;
		    		} else if (flagy==3&&e[i][j]==1) {
		    			flagy=4;
		    		}
		    	}
		    	if (j==0) {
		    		i3=((i1+i2)/2);
		    	}
		    	if (j==s-1) {
		    		i4=((i1+i2)/2);
		    	}
		    	if (flagy!=3&&flagy!=2) {
		    		OKy=false;
		    	}
		    }
		    if (OKy) {
		    	for (int j=0; j<s; j++) {
		    		for (int i=0; i<s; i++) {
		    			if ( e[i][j]==1) {
		    				stroke(0, 255, 0);
		    			} else {
		    				stroke(0, 0, 255);
		    			}
		    		}
		    	}
		    	stroke(0);
		    }

		    boolean OKx=true;
		    int flagx;
		    int j1=0;
		    int j2=s-1;
		    int j3=0;
		    int j4=0;
		    for (int i=0; i<s; i++) {
		    	flagx=0;
		    	for (int j=0; j<s; j++) {
		    		if (flagx==0&&e[i][j]==0) {
		    			flagx=1;
		    		} else if (flagx==0&&e[i][j]==1) {
		    			flagx=2;
		    			j1=j;
		    		} else if (flagx==1&&e[i][j]==1) {
		    			flagx=2;
		    			j1=j;
		    		} else if (flagx==2&&e[i][j]==0) {
		    			flagx=3;
		    			j2=j;
		    		} else if (flagx==3&&e[i][j]==1) {
		    			flagx=4;
		    		}
		    	}
		    	if (i==0) {
		    		j3=((j1+j2)/2);
		    	}
		    	if (i==s-1) {
		    		j4=((j1+j2)/2);
		    	}
		    	if (flagx!=3&&flagx!=2) {
		    		OKx=false;
		    	}
		    }
		    if (OKx) {
		    	for (int j=0; j<s; j++) {
		    		for (int i=0; i<s; i++) {
		    			if ( e[i][j]==1) {
		    				stroke(255);
		    			} else {
		    				stroke(0, 0, 255);
		    			}
		    		}
		    	}
		    	stroke(0);
		    }
		}
	}


}