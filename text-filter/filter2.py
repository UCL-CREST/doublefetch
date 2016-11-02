import sys
#print "args: in-->",sys.argv[1], "   out-->:", sys.argv[2]

#0 start
#1 got funcDecl
#2 got {
#3 got get_user() or copy_from_user()	
#4 writing trans
#0 got }
class Filter:
	def __init__(self, inadd, outadd):
	 	self.infile = inadd
	 	self.outfile = outadd
	 	self.origin = ""
	 	self.curState = 0
	 	self.in_file_handler = None
	 	self.out_file_handler = None
	 	self.isOutfileOpen = False

	def get_infile_handler(self):
		return open(self.infile, "r")

	def get_outfile_handler(self):
		return open(self.outfile, "w+")

	def identify(self, line):
	 
	 	if line.find("get_user") == 0:
	 		return "trans"
	 	elif line.find("copy_from_user") == 0:
	 		return "trans"
	 	elif line.find("case") == 0 :
	 		return "case"
	 	elif line.find("default") == 0:
	 		return "case"
	 	elif line.find("{") == 0:
	 		return "{"
	 	elif line.find("}") == 0 :
	 		return "}"
	 	elif  line == '\n' :
	 		return "blank"
	 	elif line.find(' ') == 0:
	 		return "blank"
	 	else:
	 		return "funcDecl"

	def get_end_loc(self, strs, start):
		l = len(strs)
		if l == start: #index out of range
			return -1
		i = start # start position
		left = 0
		right = 0
		while True:
			if strs[i] == '(':
				left = left + 1
			elif strs[i] == ')':
				right = right + 1
				if left + 1 == right:
					return i
			else: 
				pass
			i = i + 1
			if i == l: # if the function stmt is incomplete, return -1
				break
		return -1



	def is_same(self, in_str1, in_str2):
		str1 = in_str1.replace(" ", "")
		str2 = in_str2.replace(" ", "")

		if str1.find('get_user') != -1 and str2.find('get_user') != -1:
			# get start loc
			loc1s = str1.find(',') 
			loc2s = str2.find(',') 
			if loc1s == -1 or loc2s == -1 :
				return False 

			# get end loc
			loc1e = self.get_end_loc(str1, loc1s)
			loc2e = self.get_end_loc(str2, loc2s)

			if loc1e == -1 or loc2e == -1 :
				return False # incomplete line, introduce false negatives

			#print "get_user: loc1s, loc1e", loc1s, loc1e
			#print "get_user: loc2s, loc2e", loc2s, loc2e
			#print str1[loc1s:loc1e],"<-->", str2[loc2s:loc2e]
			if(str1[loc1s:loc1e] == str2[loc2s:loc2e]):
				#print "=> get_user match"
				if str1[loc1s:loc1e].find('++') != -1:
					return False
				else:
					return True
			else:
				#print "=> get_user dismatch"
				return False
				
		elif str1.find('copy_from_user') != -1 and str2.find('copy_from_user') != -1:
			# get start loc
			loc1s = str1.find(',')
			loc2s = str2.find(',')
			if loc1s == -1 or loc2s == -1 :
				return False  # introduce false negatives
			loc1s = loc1s + 1 # search from next char
			loc2s = loc2s + 1
			# get end loc
			loc1e = str1.find(',',loc1s)	
			loc2e = str2.find(',',loc2s)	
			#loc11 = str1.rfind(',')
			#loc22 = str2.rfind(',')		
			if loc1e == -1 or loc2e == -1 :
				return False # introduce false negatives
			
			#print "copy_from_user: loc1s, loc1e", loc1s, loc1e
			#print "copy_from_user: loc2s, loc2e", loc2s, loc2e
			#print str1[loc1s:loc1e],"<-->", str2[loc2s:loc2e]
			if(str1[loc1s:loc1e] == str2[loc2s:loc2e]):
				#print "=> copy_from_user match"
				if str1[loc1s:loc1e].find('++') != -1:
					return False
				else:
					return True
				 
			else:
				#print "=> copy_from_user dismatch"
				return False
		
		elif  str1.find('get_user') != -1 and str2.find('copy_from_user') != -1:
			loc1s = str1.find(',')
			loc2s = str2.find(',')
			if loc1s == -1 or loc2s == -1 :
				return False  # introduce false negatives

			loc2s = loc2s + 1
			
			loc1e = self.get_end_loc(str1, loc1s)
			loc2e = str2.find(',',loc2s)

			if loc1e == -1 or loc2e == -1 :
				return False # introduce false negatives

			#print "get_user: loc1s, loc1e", loc1s, loc1e
			#print "copy_from_user: loc2s, loc2e", loc2s, loc2e
			#print str1[loc1s:loc1e],"<-->", str2[loc2s:loc2e]
			if(str1[loc1s:loc1e] == str2[loc2s:loc2e]):
				#print "=> get_user & copy_from_user match"
				if str1[loc1s:loc1e].find('++') != -1:
					return False
				else:
					return True
				 
			else:
				#print "=> get_user & copy_from_user match dismatch"
				return False

		elif  str1.find('copy_from_user') != -1 and str2.find('get_user') != -1:
			loc1s = str1.find(',')
			loc2s = str2.find(',')
			if loc1s == -1 or loc2s == -1 :
				return False  # introduce false negatives

			loc1s = loc1s + 1			

			loc1e = str1.find(',',loc1s)
			loc2e = self.get_end_loc(str2, loc2s)
			if loc1e == -1 or loc2e == -1 :
				return False # introduce false negatives

			#print "copy_from_user: loc1s, loc1e", loc1s, loc1e
			#print "get_user: loc2s, loc2e", loc2s, loc2e
			#print str1[loc1s:loc1e],"<-->", str2[loc2s:loc2e]
			if(str1[loc1s:loc1e] == str2[loc2s:loc2e]):
				#print "=> copy_from_user match & get_user"
				if str1[loc1s:loc1e].find('++') != -1:
					return False
				else:
					return True
				 
			else:
				#print "=> copy_from_user match & get_user"
				return False

		else:
			#print "is_same error!\n"
			return False

	

	#in_list: all the transfer funcs
	#out_list: pick out all the identical transfer funcs
	#filter the identical trans
	def process_skeleton(self, in_list):
		#in_list['line'] = line
		#in_list['verify'] = vline
		#in_list['flag'] = False
		out_list = []
		l = len(in_list)
		s1_case_index = -1
		s2_case_index = -1

		s1_case_level = 0 #case level, 0 indicates outside the switch
		s1 = 0
		while (s1 < l-1):
			if in_list[s1]['verify'] == 'case':
				s1_case_index = s1
				s1 = s1 + 1
				s1_case_level = s1_case_level + 1
			#print "s1 line = ", in_list[s1]['line']
			#print "s1 case level = ", s1_case_level
			#print "s1 case index = ", s1_case_index
			#print "s1 = ", s1
			#print "\n"
			
			s2_case_level = s1_case_level
			s2 = s1 + 1			
			while s2 < l:
				if in_list[s2]['verify'] == 'case':
					s2_case_index = s2
					s2_case_level = s2_case_level + 1
					s2 = s2 + 1
				#print "s2 line = ", in_list[s2]['line']
				#print "s2 case level = ", s2_case_level
				#print "s2 case index = ", s2_case_index
				#print "s2 = ", s2
				#print "\n"

				if (s1_case_level == 0) and (s2_case_level == 0):
					#print 's1_case_level == 0, s2_case_level == 0\n'
					if self.is_same(in_list[s1]['line'],in_list[s2]['line']):
						in_list[s1]['flag'] = True
						in_list[s2]['flag'] = True
						#print "add"
					else:
						#print "abandon"
						pass
				elif(s1_case_level == 0) and (s2_case_level != 0):
					#print 's1_case_level == 0, s2_case_level != 0\n'
					if self.is_same(in_list[s1]['line'],in_list[s2]['line']):
						in_list[s1]['flag'] = True
						in_list[s2]['flag'] = True
						in_list[s2_case_index]['flag'] = True
						#print "add"
					else:
						#print "abandon"
						pass
				elif(s1_case_level != 0) and (s1_case_level == s2_case_level):
					#print 's1_case_level == s2_case_level, s1_case_level != 0\n'
					if self.is_same(in_list[s1]['line'],in_list[s2]['line']):
						in_list[s1]['flag'] = True
						in_list[s2]['flag'] = True
						in_list[s1_case_index]['flag'] = True
						#print "add"
					else:
						#print "abandon"
						pass
				elif(s1_case_level != 0) and (s2_case_level != 0) and (s1_case_level != s2_case_level):
					#print 's1_case_level != s2_case_level, s1_case_level != 0, s2_case_level != 0\n'
					#print "abandon differ cases"
					pass
				else:
					#print 'error 0\n'
					pass

				s2 = s2 + 1
			s1 = s1 + 1

		out_list = []
		for i in in_list:
			if i['flag'] == True:
				out_list.append(i['line'])

		return out_list


	def close_files(self):
	 	self.in_file_handler.close()
	 	if self.out_file_handler:
	 		self.out_file_handler.close()

	def main(self):
	 	self.in_file_handler = open(self.infile, "r")
	 	self.origin = self.in_file_handler.readline()
	 	#print "source file->:", self.origin
	 	temp_funcDecl = ""
	 	temp_left = ""
	 	temp_transfer = ""


	 	in_list = []
		out_list = []
	 	while True:
			line = self.in_file_handler.readline()
			#print "state: ", self.curState
			#print "line: ", line
			if line:
				vline = self.identify(line)
				if self.curState == 0 and vline == "funcDecl":
					temp_funcDecl = line
					self.curState = 1

				if self.curState == 1 and vline == "funcDecl":
					temp_funcDecl = line
					self.curState = 1

				elif self.curState == 1 and vline == "{":
					temp_left = "{"
					self.curState = 2
				
				elif self.curState == 2 and vline == "}":
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

					out_list = self.process_skeleton(in_list)
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
							self.out_file_handler.write(self.origin )
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
						#print "list empty:state->5"
				else:
					#print "error!:"
					pass
			else:
				break	
					

####################################
my_filter = Filter(sys.argv[1], sys.argv[2])
my_filter.main()
my_filter.close_files()
