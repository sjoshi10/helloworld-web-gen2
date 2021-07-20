# copyright: 2021, Michael Joseph Walsh

title "k8s helloworld-web deployment tests"

input('namespace', value: 'helloworld-web')
input('helloworld_image', value: 'k3d-registry.nemonik.com:5000/nemonik/helloworld-web:latest')

control "helloworld-web-deployment-1" do
  impact 1.0
  title "Validate helloworld-web ingress"

  describe "Ingress host is expected to be 'helloworld.nemonik.com'" do
    subject { command("kubectl get ingresses -n " + input('namespace') + " helloworld-web -o=jsonpath='{.spec.rules[0].host}' | tee shit.txt") }
    its('stdout') { should cmp 'helloworld.nemonik.com' }
  end

  describe "Ingress is expected to route traffic to 'helloworld-web' service" do
    subject { command("kubectl get ingresses -n " + input('namespace') + " helloworld-web -o=jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}'") }
    its('stdout') { should cmp 'helloworld-web' }
  end

  describe "Ingress is expected to route traffic to service http port" do
    subject { command("kubectl get ingresses -n " + input('namespace') + " helloworld-web -o=jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.name}'") }
    its('stdout') { should cmp 'http' }
  end
end

control "helloworld-web-deployment-2" do
  impact 1.0
  title "Validate helloworld-web service"

  describe "Service port is expected to be named 'http'" do
    subject { command("kubectl get service -n " + input('namespace') + " helloworld-web -o=jsonpath='{.spec.ports[0].name}'") }
    its('stdout') { should cmp "http" }
  end

  describe "Service is expected to listen on port '80'" do
    subject { command("kubectl get service -n " + input('namespace') + " helloworld-web -o=jsonpath='{.spec.ports[0].port}'") }
    its('stdout') { should cmp "80" }
  end

  describe "The Service port is expected to be a TCP port" do
    subject { command("kubectl get service -n " + input('namespace') + " helloworld-web -o=jsonpath='{.spec.ports[0].protocol}'") }
    its('stdout') { should cmp "TCP" }
  end

  describe "Service port is expected to target port 'http'" do
    subject { command("kubectl get service -n " + input('namespace') + " helloworld-web -o=jsonpath='{.spec.ports[0].targetPort}'") }
    its('stdout') { should cmp "http" }
  end
end

control "helloworld-web-deployment-3" do
  impact 1.0
  title "Validate helloworld-web pod"

  describe "Pod is running container 'k3d-registry.nemonik.com:5000/nemonik/helloworld-web:latest'" do
    subject { command("kubectl get pods -n " + input('namespace') + " -l app.kubernetes.io/component=helloworld-web -o=jsonpath='{$.items[0].spec.containers[0].image}'") }
    its('stdout') { should cmp "k3d-registry.nemonik.com:5000/nemonik/helloworld-web:latest" }
  end

  describe "Pod is running container whose port is 3000" do
    subject { command(" kubectl get pods -n " + input('namespace') + " -l app.kubernetes.io/component=helloworld-web -o=jsonpath='{$.items[0].spec.containers[0].ports[0].containerPort}'") }
    its('stdout') { should cmp "3000" }
  end

  describe "Pod is running container whose port is named 'http'" do
    subject { command(" kubectl get pods -n " + input('namespace') + " -l app.kubernetes.io/component=helloworld-web -o=jsonpath='{$.items[0].spec.containers[0].ports[0].name}'") }
    its('stdout') { should cmp "http" }
  end

  describe "Pod is running container whose port is named 'http'" do
    subject { command(" kubectl get pods -n " + input('namespace') + " -l app.kubernetes.io/component=helloworld-web -o=jsonpath='{$.items[0].spec.containers[0].ports[0].name}'") }
    its('stdout') { should cmp "http" }
  end

  describe "Pod is running container whose port is a TCP port" do
    subject { command(" kubectl get pods -n " + input('namespace') + " -l app.kubernetes.io/component=helloworld-web -o=jsonpath='{$.items[0].spec.containers[0].ports[0].protocol}'") }
    its('stdout') { should cmp "TCP" }
  end
end

control "helloworld-web-deployment-4" do
  impact 1.0
  title "Validate helloworld-web deployment"

  describe "Deployment ensure replica count is 1" do
    subject { command("kubectl get deployment -n " + input('namespace') + " helloworld-web -o=jsonpath='{$.status.replicas}'") }
    its('stdout') { should cmp "1" }
  end
end 
