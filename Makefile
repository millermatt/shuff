main: ./src/lib/**
	@mkdir -p build/lib
	@find ./src/lib/** -type f | xargs -I_mfrepl_ sh -c "cat _mfrepl_ ; echo ''; echo ''" >> ./build/lib/shuff.sh
	@chmod +x ./build/*
	@echo "*** make complete ***"

.PHONY: clean
clean:
	@rm -rf build
	@rm -f clean

.PHONY: test
test:
	@echo "Test sh"
	@find ./test/*/** -type f | xargs -n1 sh -c
	@echo "Test bash"
	@find ./test/*/** -type f | xargs -n1 bash -c
	@echo "Test zsh"
	@find ./test/*/** -type f | xargs -n1 zsh -c
