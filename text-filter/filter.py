import sys
#print "-->arges are",sys.argv[1], sys.argv[2], sys.argv[3]  

#0 start
#1 got funcDecl
#2 got {
#3 got first get_user() or copy_from_user()	
#4 getting transfer funcs
#5 got }
#6 
class Filter:
	 def __init__(self, inadd, outadd, orig):
	 	self.infile = inadd
	 	self.outfile = outadd
	 	self.origin = orig;
	 	self.curState = 0
	 	self.in_file_handler = None
	 	self.out_file_handler = None
	 	self.isOutfileOpen = False

	 def get_infile_handler(self):
	 	return open(self.infile, "r")

	 def get_outfile_handler(self):
	 	return open(self.outfile, "w+")

	 def identify(self, line):
	 	#print 'line: ', line
	 	if line.find("get_user") == 0:
	 		#print "get_user"
	 		return "trans"
	 	elif line.find("copy_from_user") == 0:
	 		#print "copy_from_user"
	 		return "trans"
	 	elif line.find("case") == 0 :
	 		#print "case"
	 		return "case"
	 	elif line.find("default") == 0:
	 		#print "default"
	 		return "case"
	 	elif line.find("{") == 0:
	 		#print "{"
	 		return "{"
	 	elif line.find("}") == 0 :
	 		#print "}"
	 		return "}"
	 	elif  line == '\n' :
	 		#print "blank"
	 		return "blank"
	 	elif line.find(' ') == 0:
	 		#print "empty"
	 		return "blank"
	 	else :
	 		#print "funcDecl"
	 		return "funcDecl"

	 def close_files(self):
	 	self.in_file_handler.close()
	 	if self.out_file_handler:
	 		self.out_file_handler.close()

	 def process_list(self, in_list):
		l = len(in_list)
		if in_list[0]['verify'] == "trans":
			i = 1
			last_case = 0
			incase = False
			while  i < l:
				if in_list[i]['verify'] == "trans" and incase == False:
					in_list[0]['flag'] = True
					in_list[i]['flag'] = True
				elif in_list[i]['verify'] == "case":
					#print "--> ", in_list[i]
					last_case = i
					incase = True
				elif in_list[i]['verify'] == "trans" and incase == True:
					in_list[0]['flag'] = True
					in_list[last_case]['flag'] = True
					in_list[i]['flag'] = True
					#print "-----> ", in_list[i]
				else:
					print 'false 1'

				i = i + 1
	

		elif in_list[0]['verify'] == "case":
			last_case = 0
			case_counter = 0
			i = 1
			while i < l:
				if in_list[i]['verify'] == "trans":
					case_counter = case_counter + 1
					if case_counter > 1:
						j = last_case
						while j < i + 1:
							in_list[j]['flag'] = True
							j = j + 1
				elif in_list[i]['verify'] == "case":
					last_case = i
					case_counter = 0
				else:
					print 'false 2'

				i = i + 1

		else:
			print 'false 3'

		out_list = []
		for i in in_list:
			if i['flag'] == True:
				out_list.append(i['line'])
		#print "out:", out_list
		return out_list


	 def main(self):
	 	self.in_file_handler = open(self.infile, "r")
	 	temp_funcDecl = ""
	 	temp_left = ""
	 	temp_trans = ""
	 	temp_case = ""
	 	in_list = []
		out_list = []
	 	while True:
			line = self.in_file_handler.readline()
			#print "line: ",line
			if line:				
				vline = self.identify(line)
				#print "line: ",vline
				if vline == "blank":
					pass

				elif self.curState == 0 and vline == "funcDecl" :
					temp_funcDecl = line
					self.curState = 1 #got decl

				elif self.curState == 1  and  vline == "funcDecl": 
					temp_funcDecl = line
					self.curState = 1

				elif self.curState == 1  and  vline == "}": 
					self.curState = 0 # half bracket

				elif self.curState == 1 and vline == "{" :
					temp_left = "{"
					self.curState = 2  # got bracket
				
				elif self.curState == 2 and vline == "}" :
					self.curState = 0

				elif self.curState == 2 and (vline == "trans" or vline == "case"):
					self.curState = 3
					#print "state 3\n"
					dict_item = {}
					dict_item['line'] = line
					dict_item['verify'] = vline
					dict_item['flag'] = False
					in_list.append(dict_item)
					while True:
						line = self.in_file_handler.readline()
						vline = self.identify(line)
						#print "while line: ", line
						if not line:
							break
							
						if self.identify(line) == "}" :
							self.curState = 0
							#print "break"
							break

						if self.curState == 3 and (vline == "trans" or vline == "case"):
							dict_item = {}
							dict_item['line'] = line
							dict_item['verify'] = vline
							dict_item['flag'] = False
							in_list.append(dict_item)
							#print "append ", vline

					#print "inlist--->: ", in_list
					#print "\n"

					if len(in_list) > 1:
						out_list = self.process_list(in_list)
						#print "outlist=====>: ", out_list

						if out_list:
							if self.isOutfileOpen:
								self.out_file_handler.write(temp_funcDecl)
								self.out_file_handler.write(temp_left+'\n')
								for str in out_list:
									self.out_file_handler.write(str)
								self.out_file_handler.write("}\n")
							else:
								self.out_file_handler = open(self.outfile, "w")
								self.isOutfileOpen = True
								self.out_file_handler.write(self.origin + '\n')
								self.out_file_handler.write(temp_funcDecl)
								self.out_file_handler.write(temp_left+"\n")
								for str in out_list:
									self.out_file_handler.write(str)
								self.out_file_handler.write("}\n")
							in_list = [] #reset buffers
							out_list = []
						else:
							in_list = [] #reset buffers
							out_list = []
					else:
						in_list = [] #reset buffers
						out_list = []
						#print "list empty:state->5"
				else:
					#print  "# error #: " + line
					pass


				#sprint "-->state: ", self.curState

			else:
				break
		

####################################
my_filter = Filter(sys.argv[1], sys.argv[2], sys.argv[3])
my_filter.main()
my_filter.close_files()
