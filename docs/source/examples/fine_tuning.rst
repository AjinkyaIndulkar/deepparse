.. role:: hidden
    :class: hidden-section

Retrain a Pretrained Model
**************************

.. code-block:: python

    import poutyne

    from deepparse import download_from_public_repository
    from deepparse.dataset_container import PickleDatasetContainer
    from deepparse.parser import AddressParser


First, let's download the train and test data from the public repository.

.. code-block:: python

    saving_dir = "./data"
    file_extension = "p"
    training_dataset_name = "sample_incomplete_data"
    test_dataset_name = "test_sample_data"
    download_from_public_repository(training_dataset_name, saving_dir, file_extension=file_extension)
    download_from_public_repository(test_dataset_name, saving_dir, file_extension=file_extension)

Now let's create a training and test container.

.. code-block:: python

    training_container = PickleDatasetContainer(os.path.join(saving_dir,
                                                             training_dataset_name + "." + file_extension))
    test_container = PickleDatasetContainer(os.path.join(saving_dir,
                                                         test_dataset_name + "." + file_extension))

We will retrain the ``FastText`` version of our pretrained model.

.. code-block:: python

    address_parser = AddressParser(model_type="fasttext", device=0)

Now, let's retrain for ``5`` epochs using a batch size of ``8`` since the data is really small for the example.
Let's start with the default learning rate of ``0.01`` and use a learning rate scheduler to lower the learning rate as we progress.

.. code-block:: python

    # Reduce LR by a factor of 10 each epoch
    lr_scheduler = poutyne.StepLR(step_size=1, gamma=0.1)

The checkpoints (ckpt) are saved in the default ``"./checkpoints"`` directory, so if you wish to retrain
another model (let's say BPEmb), you need to change the ``logging_path`` directory; otherwise, you will get
an error when retraining since Poutyne will try to use the last checkpoint.


.. code-block:: python

    address_parser.retrain(training_container, train_ratio=0.8, epochs=5, batch_size=8, num_workers=2, callbacks=[lr_scheduler])

Now, let's test our fine-tuned model using the best checkpoint (default parameter).

.. code-block:: python

    address_parser.test(test_container, batch_size=256)

Now let's retrain the ``FastText`` version but with an attention mechanism.

.. code-block:: python

    address_parser = AddressParser(model_type="fasttext", device=0, attention_mechanism=True)

Since the previous checkpoints were saved in the default ``"./checkpoints"`` directory, we need to use a new one.
Otherwise, poutyne will try to reload the previous checkpoints, and our model has changed.

.. code-block:: python

    address_parser.retrain(training_container,
                           train_ratio=0.8,
                           epochs=5,
                           batch_size=8,
                           num_workers=2,
                           callbacks=[lr_scheduler],
                           logging_path="checkpoints_attention")

Now, let's test our fine-tuned model using the best checkpoint (default parameter).

.. code-block:: python

    address_parser.test(test_container, batch_size=256)