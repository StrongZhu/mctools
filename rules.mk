##
# New build wrappers.
# Use: "make V=1" to see full GCC output.
#
ifdef V
  ifeq ("$(origin V)", "command line")
    KBUILD_VERBOSE = $(V)
  endif
endif
ifndef KBUILD_VERBOSE
  KBUILD_VERBOSE = 0
endif
ifeq ($(KBUILD_VERBOSE),1)
Q            =
MFLAGS       =
LIBTOOLFLAGS = 
REDIRECT     =
else
Q            = @
MFLAGS       = --no-print-directory
LIBTOOLFLAGS = --silent
REDIRECT     = >/dev/null
endif
export Q MXFLAGS REDIRECT

##
# Auto dependency creation
# Put the following line in the beginning of your Makefile:
# include rules.mk
# And this at the end:
# ifneq ($(MAKECMDGOALS),clean)
# -include $(DEPS)
# endif
#
##
# Smart autodependecy generation via GCC -M.
.%.d: %.c
	$(Q)$(SHELL) -ec "$(CC) -MM $(CFLAGS) $(CPPFLAGS) $< 2>/dev/null \
		| sed 's,.*: ,$*.o $@ : ,g' > $@; \
                [ -s $@ ] || rm -f $@"

##
# Override default implicit rules
%.o: %.c
ifdef Q
	@printf "  CC      $(subst $(ROOTDIR),,$(shell pwd))/$@\n"
endif
	$(Q)$(CC) $(CFLAGS) $(CPPFLAGS) -c -o $@ $<

%.c: %.y
ifdef Q
	@printf "  YACC    $(subst $(ROOTDIR),,$(shell pwd))/$@\n"
endif
	$(Q)$(YACC) $<
	-$(Q)mv y.tab.c $@ || mv $(<:.y=.tab.c) $@

%: %.o
ifdef Q
	@printf "  LINK    $(subst $(ROOTDIR),,$(shell pwd))/$@\n"
endif
	$(Q)$(CC) $(CFLAGS) $(LDFLAGS) -Wl,-Map,$@.map -o $@ $^ $(LDLIBS$(LDLIBS-$(@)))

(%.o): %.c
ifdef Q
	@printf "  AR      $(subst $(ROOTDIR),,$(shell pwd))/$(notdir $@)($%)\n"
endif
	$(Q)$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $*.o
	$(Q)$(AR) $(ARFLAGS) $@ $*.o

