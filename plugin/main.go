package k8s_client

import (
	"k8s.io/kubernetes/pkg/client/unversioned"
	restclient "k8s.io/kubernetes/pkg/client/restclient"
)

// NewClient creates a new kubernetes client.
func NewClient(host, username, password string) (*client.Clientset, error) {
	config := &restclient.Config{
		Host:     host,
		Username: username,
		Password: password,
		// TODO: For e2e cluster. Need one with DNS.
		Insecure: true,
	}	
	client, err := unversioned.New(config)
	if err != nil {
	  // handle error
	}
	pods, err := client.Pods(api.NamespaceDefault).List(api.ListOptions{})
	if err != nil {
	  // handle error
	}
}